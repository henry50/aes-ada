with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with AES.Key_Expansion;
with AES.Util; use AES.Util;
with AES.Internal_Util; use AES.Internal_Util;
with AES.Cipher;
with AES.Inv_Cipher;
with Ada.Characters.Latin_1;

package body AES.Test is

procedure Test_Header(Title: String) is
    Len: Natural := Title'Length;
    Pad: Natural;
begin
    if Len >= 32 then
        Pad := 0;
    else
        Pad := (32 - Len) / 2;
    end if;
    Put_Line("================================");
    for I in 1..Pad loop
        Put(" ");
    end loop;
    Put(Title);
    for I in 32 - Len - Pad..32 loop
        Put(" ");
    end loop;    
    New_Line;
    Put_Line("================================");    
end Test_Header;

function Assert(Condition: Boolean) return String is
    use Ada.Characters.Latin_1;
    GREEN: String := ESC & "[32m";
    RED: String := ESC & "[31m";
    CLEAR: String := ESC & "[0m";
begin
    if Condition then
        return GREEN & " [success]" & CLEAR;
    else
        return RED & " [failure]" & CLEAR;
    end if;
end Assert;

procedure Test_Key_Expansion is
    Lengths: array(0..2) of String(1..3) := ("128", "192", "256");
    Key_128: AES_128_Key := Hex_To_Bytes("2b7e151628aed2a6abf7158809cf4f3c");
    Key_192: AES_192_Key := Hex_To_Bytes("8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b");
    Key_256: AES_256_Key := Hex_To_Bytes("603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4");
    Hex: String(1..32);
    -- From Appendix A
    type Expected_Round_Keys is array(Natural range <>) of String(1..32);
    Expected_128: Expected_Round_Keys := (
        "2b7e151628aed2a6abf7158809cf4f3c",
        "a0fafe1788542cb123a339392a6c7605",
        "f2c295f27a96b9435935807a7359f67f",
        "3d80477d4716fe3e1e237e446d7a883b",
        "ef44a541a8525b7fb671253bdb0bad00",
        "d4d1c6f87c839d87caf2b8bc11f915bc",
        "6d88a37a110b3efddbf98641ca0093fd",
        "4e54f70e5f5fc9f384a64fb24ea6dc4f",
        "ead27321b58dbad2312bf5607f8d292f",
        "ac7766f319fadc2128d12941575c006e",
        "d014f9a8c9ee2589e13f0cc8b6630ca6"
    );
    Expected_192: Expected_Round_Keys := (
        "8e73b0f7da0e6452c810f32b809079e5",
        "62f8ead2522c6b7bfe0c91f72402f5a5",
        "ec12068e6c827f6b0e7a95b95c56fec2",
        "4db7b4bd69b5411885a74796e92538fd",
        "e75fad44bb095386485af05721efb14f",
        "a448f6d94d6dce24aa326360113b30e6",
        "a25e7ed583b1cf9a27f939436a94f767",
        "c0a69407d19da4e1ec1786eb6fa64971",
        "485f703222cb8755e26d135233f0b7b3",
        "40beeb282f18a2596747d26b458c553e",
        "a7e1466c9411f1df821f750aad07d753",
        "ca4005388fcc5006282d166abc3ce7b5",
        "e98ba06f448c773c8ecc720401002202"
    );
    Expected_256: Expected_Round_Keys := (
        "603deb1015ca71be2b73aef0857d7781",
        "1f352c073b6108d72d9810a30914dff4",
        "9ba354118e6925afa51a8b5f2067fcde",
        "a8b09c1a93d194cdbe49846eb75d5b9a",
        "d59aecb85bf3c917fee94248de8ebe96",
        "b5a9328a2678a647983122292f6c79b3",
        "812c81addadf48ba24360af2fab8b464",
        "98c5bfc9bebd198e268c3ba709e04214",
        "68007bacb2df331696e939e46c518d80",
        "c814e20476a9fb8a5025c02d59c58239",
        "de1369676ccc5a71fa2563959674ee15",
        "5886ca5d2e2f31d77e0af1fa27cf73c3",
        "749c47ab18501ddae2757e4f7401905a",
        "cafaaae3e4d59b349adf6acebd10190d",
        "fe4890d1e6188d0b046df344706c631e"
    );
begin
    for I in 0..2 loop
        Test_Header("Test " & Lengths(I) & "-bit key expansion");
        declare
            K: Key := (case I is
                when 0 => Key_128,
                when 1 => Key_192,
                when 2 => Key_256
            );
            Expected: Expected_Round_Keys := (case I is
                when 0 => Expected_128,
                when 1 => Expected_192,
                when 2 => Expected_256
            );
            Ks: Key_Schedule := AES.Key_Expansion.Key_Expansion(K);
        begin
            Put(Lengths(I) & "-bit key: "); Put_Line(Bytes_To_Hex(K));
            for J in Ks'Range loop
                Put("Round "); Put(J, 2); Put(": ");
                Hex := Bytes_To_Hex(Ks(J));
                Put(Hex);
                Put_Line(Assert(Expected(J) = Hex));
            end loop;
            New_Line;
        end;
    end loop;
end Test_Key_Expansion;

procedure Test_Appendix_B is
    Input: Input_Buffer := Hex_To_Bytes("3243f6a8885a308d313198a2e0370734");
    St: State := Block_To_State(Input);
    Key_128: AES_128_Key := Hex_To_Bytes("2b7e151628aed2a6abf7158809cf4f3c");
    Result: State := AES.Cipher.Cipher(St, Key_128);
    Expected: State := (
        (16#39#, 16#02#, 16#dc#, 16#19#),
        (16#25#, 16#dc#, 16#11#, 16#6a#),
        (16#84#, 16#09#, 16#85#, 16#0b#),
        (16#1d#, 16#fb#, 16#97#, 16#32#)
    );
begin
    Test_Header("Appendix B Cipher Example");
    Print_State(Result);
    Put_Line(Assert(Result = Expected));
end Test_Appendix_B;

procedure Test_Appendix_C is
    Lengths: array(0..2) of String(1..3) := ("128", "192", "256");
    Input_Hex: String := "00112233445566778899aabbccddeeff";
    Input: Input_Buffer := Hex_To_Bytes(Input_Hex);
    St: State := Block_To_State(Input);
    Key_128: AES_128_Key := Hex_To_Bytes("000102030405060708090a0b0c0d0e0f");
    Key_192: AES_192_Key := Hex_To_Bytes("000102030405060708090a0b0c0d0e0f1011121314151617");
    Key_256: AES_256_Key := Hex_To_Bytes("000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f");
    Expected: array (0..2) of String(1..32) := ("69c4e0d86a7b0430d8cdb78070b4c55a", "dda97ca4864cdfe06eaf70a0ec0d7191", "8ea2b7ca516745bfeafc49904b496089");
begin
    Test_Header("Appendix C tests");
    Put_Line("Input:                " & Bytes_To_Hex(Input));
    New_Line;
    for I in 0..2 loop
        declare
            K: Key := (case I is
                when 0 => Key_128,
                when 1 => Key_192,
                when 2 => Key_256
            );
            Result_St: State := AES.Cipher.Cipher(St, K);
            Inv_Result_St: State := AES.Inv_Cipher.Inv_Cipher(Result_St, K);
            Result: String := Bytes_To_Hex(State_To_Block(Result_St));
            Inv_Result: String := Bytes_To_Hex(State_To_Block(Inv_Result_St));
        begin
            Put("Test " & Lengths(I) & "-bit encrypt: ");
            Put(Result);
            Put_Line(Assert(Result = Expected(I)));
            put("Test " & Lengths(I) & "-bit decrypt: ");
            Put(Inv_Result);
            Put_Line(Assert(Inv_Result = Input_Hex));
            New_Line;
        end;
    end loop;
end Test_Appendix_C;

procedure Test_Padding is
    Hex_9: String := "00112233445566778899";
    Hex_16: String := "00112233445566778899aabbccddeeff";
    Input_9: Input_Buffer := Hex_To_Bytes(Hex_9);
    Input_16: Input_Buffer := Hex_To_Bytes(Hex_16);
    Padded_9: States := Input_To_States(Input_9, Encrypt);
    Padded_16: States := Input_To_States(Input_16, Encrypt);
    Unpadded_9: String := Bytes_To_Hex(States_To_Output(Padded_9, Decrypt));
    Unpadded_16: String := Bytes_To_Hex(States_To_Output(Padded_16, Decrypt));
    Expected_Padded_9: States := (1 => (
        (16#00#, 16#44#, 16#88#, 16#06#),
        (16#11#, 16#55#, 16#99#, 16#06#),
        (16#22#, 16#66#, 16#06#, 16#06#),
        (16#33#, 16#77#, 16#06#, 16#06#)
    ));
    Expected_Padded_16: States := ((
        (16#00#, 16#44#, 16#88#, 16#cc#),
        (16#11#, 16#55#, 16#99#, 16#dd#),
        (16#22#, 16#66#, 16#aa#, 16#ee#),
        (16#33#, 16#77#, 16#bb#, 16#ff#)
    ),(
        (16#10#, 16#10#, 16#10#, 16#10#),
        (16#10#, 16#10#, 16#10#, 16#10#),
        (16#10#, 16#10#, 16#10#, 16#10#),
        (16#10#, 16#10#, 16#10#, 16#10#)
    ));
begin
    Test_Header("Test input padding");
    Put_Line("9 bytes");
    Print_State(Padded_9(0));
    Put_Line(Assert(Padded_9 = Expected_Padded_9));
    Put_Line("16 bytes");
    for I in Padded_16'Range loop
        Print_State(Padded_16(I));
    end loop;
    Put_Line(Assert(Padded_16 = Expected_Padded_16));
    New_Line;
    Test_Header("Test output padding");
    Put_Line("9 bytes");
    Put(Unpadded_9);
    Put_Line(Assert(Unpadded_9 = Hex_9));
    Put_Line("16 bytes");
    Put(Unpadded_16);
    Put_Line(Assert(Unpadded_16 = Hex_16));
    New_Line;
end Test_Padding;

procedure Test_CBC_1 is
    Input_Hex: String := "6bc1bee22e409f96e93d7e117393172a";
    Input: Input_Buffer := Hex_To_Bytes(Input_Hex);
    K: AES_128_Key := Hex_To_Bytes("2b7e151628aed2a6abf7158809cf4f3c");
    IV: Init_Vector := Hex_To_Bytes("000102030405060708090A0B0C0D0E0F");
    Output: Output_Buffer := AES_CBC_128(Input, K, IV, Encrypt);
    Output_Hex: String := Bytes_To_Hex(Output);
    Decrpyted: String := Bytes_To_Hex(AES_CBC_128(Output, K, IV, Decrypt));
    -- From openssl
    Expected: String := "7649abac8119b246cee98e9b12e9197d8964e0b149c10b7b682e6e39aaeb731c";
begin
    Test_Header("Test single block 128-bit CBC mode");
    Put("Encrypted: " & Output_Hex);
    Put_Line(Assert(Output_Hex = Expected));
    Put("Decrypted: " & Decrpyted);
    Put_Line(Assert(Decrpyted = Input_Hex));
    New_Line;
end Test_CBC_1;

procedure Test_CBC_2 is
    Input_Hex: String := "f869e8239606a44343f8627cc29a683bd0f431ab80f7121a1a74cb9056d614c5";
    Input: Input_Buffer := Hex_To_Bytes(Input_Hex);
    K: AES_192_Key := Hex_To_Bytes("8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b");
    IV: Init_Vector := Hex_To_Bytes("00112233445566778899AABBCCDDEEFF");
    Output: Output_Buffer := AES_CBC_192(Input, K, IV, Encrypt);
    Output_Hex: String := Bytes_To_Hex(Output);
    Decrypted: String := Bytes_To_Hex(AES_CBC_192(Output, K, IV, Decrypt));
    -- From openssl
    Expected: String := "7162fa4e6f8b0aacaa28051a3c6983540e6070509aa148d8c733f824649f5183c12fd81c5f3652df2be23f3985c85f53";
begin
    Test_Header("Test multi block 192-bit CBC mode");
    Put("Encrypted: " & Output_Hex);
    Put_Line(Assert(Output_Hex = Expected));
    Put("Decrypted: " & Decrypted);
    Put_Line(Assert(Decrypted = Input_Hex));
    New_Line;
end Test_CBC_2;

procedure Test_CBC_3 is
    -- All expected values are from openssl
    Input_Hex: String := "4fd547bdf3d592e7ed6fffc612012dd21363e2a4fbdf7240ba85b472f1d67c86effa75cc3e";
    Input: Input_Buffer := Hex_To_Bytes(Input_Hex);
    Key_128: AES_128_Key := Hex_To_Bytes("1c0b2606fa60a1c91ecf315e4f411549");
    Key_192: AES_192_Key := Hex_To_Bytes("4aca3ffad874fbaa34420427fe536318dada2338db528403");
    Key_256: AES_256_Key := Hex_To_Bytes("1bcc5d3fbeb41a72d2877a01bfe6935978cc421140dafede3216ed0301c2ffab");
    IV: Init_Vector := Hex_To_Bytes("f2534600dae256a3dacbc9d33b01bef7");
    Encrypt_128: Output_Buffer := AES_CBC_128(Input, Key_128, IV, Encrypt);
    Encrypt_128_Hex: String := Bytes_To_Hex(Encrypt_128);
    Expected_128: String := "8f238fe892fac1d72ba03974ba42fd7bcb40e8cd65d88fb349e9fe0ccc0806f287c699ea009537dd5b4515a7d75cdd7e";
    Decrypt_128: String := Bytes_To_Hex(AES_CBC_128(Encrypt_128, Key_128, IV, Decrypt));
    Encrypt_192: Output_Buffer := AES_CBC_192(Input, Key_192, IV, Encrypt);
    Encrypt_192_Hex: String := Bytes_To_Hex(Encrypt_192);
    Expected_192: String := "400e162d6419d346d62054b77a575190e3fb6ac4e8925ef3f970c0c53049f904b2aa98ecabbceec481fb1c1dac4654e7";
    Decrypt_192: String := Bytes_To_Hex(AES_CBC_192(Encrypt_192, Key_192, IV, Decrypt));
    Encrypt_256: Output_Buffer := AES_CBC_256(Input, Key_256, IV, Encrypt);
    Encrypt_256_Hex: String := Bytes_To_Hex(Encrypt_256);
    Expected_256: String := "5267c0b11cfa578444f55fb0e71a46877fdc90e896dc121f9ea349de4de77f6f64f16d3a0a36f1cf02a492ad94193075";
    Decrypt_256: String := Bytes_To_Hex(AES_CBC_256(Encrypt_256, Key_256, IV, Decrypt));
begin
    Test_Header("Test all key sizes CBC mode");
    Put("128-bit Encrypt: " & Encrypt_128_Hex);
    Put_Line(Assert(Encrypt_128_Hex = Expected_128));
    Put("128-bit Decrypt: " & Decrypt_128);
    Put_Line(Assert(Decrypt_128 = Input_Hex));
    Put("192-bit Encrypt: " & Encrypt_192_Hex);
    Put_Line(Assert(Encrypt_192_Hex = Expected_192));
    Put("192-bit Decrypt: " & Decrypt_192);
    Put_Line(Assert(Decrypt_192 = Input_Hex));
    Put("256-bit Encrypt: " & Encrypt_256_Hex);
    Put_Line(Assert(Encrypt_256_Hex = Expected_256));
    Put("256-bit Decrypt: " & Decrypt_256);
    Put_Line(Assert(Decrypt_256 = Input_Hex));
end Test_CBC_3;

procedure Run_Tests is
begin
    Put_Line("Running tests...");
    Test_Key_Expansion;
    Test_Appendix_B;
    Test_Appendix_C;
    Test_Padding;
    Test_CBC_1;
    Test_CBC_2;
    Test_CBC_3;
end Run_Tests;

end AES.Test;
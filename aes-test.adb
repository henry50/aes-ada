with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with AES.Key_Expansion;
with AES.Util; use AES.Util;
with AES.Internal_Util; use AES.Internal_Util;
with AES.Cipher;
with AES.Inv_Cipher;

package body AES.Test is

--- TODO
-- Test CBC methods

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

procedure Test_Key_Expansion is
    Lengths: array(0..2) of String(1..3) := ("128", "192", "256");
    Key_128: AES_128_Key := Hex_To_Bytes("2b7e151628aed2a6abf7158809cf4f3c");
    Key_192: AES_192_Key := Hex_To_Bytes("8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b");
    Key_256: AES_256_Key := Hex_To_Bytes("603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4");
begin
    for I in 0..2 loop
        Test_Header("Test " & Lengths(I) & "-bit key expansion");
        declare
            K: Key := (case I is
                when 0 => Key_128,
                when 1 => Key_192,
                when 2 => Key_256
            );
            Ks: Key_Schedule := AES.Key_Expansion.Key_Expansion(K);
        begin
            Put(Lengths(I) & "-bit key: "); Put_Line(Bytes_To_Hex(K));
            for J in Ks'Range loop
                Put("Round "); Put(J, 2); Put(": ");
                Put_Line(Bytes_To_Hex(Ks(J)));
            end loop;
        end;
    end loop;
end Test_Key_Expansion;

procedure Test_Appendix_B is
    Input: Input_Buffer := Hex_To_Bytes("3243f6a8885a308d313198a2e0370734");
    St: State := Block_To_State(Input);
    Key_128: AES_128_Key := Hex_To_Bytes("2b7e151628aed2a6abf7158809cf4f3c");
    Result: State := AES.Cipher.Cipher(St, Key_128);
begin
    Test_Header("Appendix B Cipher Example");
    Print_State(Result);
end Test_Appendix_B;

procedure Test_Appendix_C is
    Lengths: array(0..2) of String(1..3) := ("128", "192", "256");
    Input: Input_Buffer := Hex_To_Bytes("00112233445566778899aabbccddeeff");
    St: State := Block_To_State(Input);
    Key_128: AES_128_Key := Hex_To_Bytes("000102030405060708090a0b0c0d0e0f");
    Key_192: AES_192_Key := Hex_To_Bytes("000102030405060708090a0b0c0d0e0f1011121314151617");
    Key_256: AES_256_Key := Hex_To_Bytes("000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f");
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
            Put_Line(Result);
            put("Test " & Lengths(I) & "-bit decrypt: ");
            Put_Line(Inv_Result);
            New_Line;
        end;
    end loop;
end Test_Appendix_C;

procedure Run_Tests is
begin
    Put_Line("Running tests...");
    Test_Key_Expansion;
    Test_Appendix_B;
    Test_Appendix_C;
end Run_Tests;

end AES.Test;
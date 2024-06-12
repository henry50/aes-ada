# aes-ada

The Advanced Encryption Standard implemented in Ada.

**This implementation may not be cryptographically secure.**

The `AES` package provides functions for single blocks and CBC mode with 128, 192 and 256 bit keys.
```ada
type Byte is mod 2**8;
type Bytes is array (Natural range <>) of Byte;
subtype Block_Bytes is Bytes(0..15);
subtype Input_Buffer is Bytes;
subtype Init_Vector is Bytes(0..15);
subtype Output_Buffer is Bytes;
subtype Key is Bytes;
subtype AES_128_Key is Key(0..15);
subtype AES_192_Key is Key(0..23);
subtype AES_256_Key is Key(0..31);
type Operation is (Encrypt, Decrypt);

function AES_Block_128(Input: Block_Bytes; K: AES_128_Key; Op: Operation) return Block_Bytes;
function AES_Block_192(Input: Block_Bytes; K: AES_192_Key; Op: Operation) return Block_Bytes;
function AES_Block_256(Input: Block_Bytes; K: AES_256_Key; Op: Operation) return Block_Bytes;

function AES_CBC_128(Input: Input_Buffer; K: AES_128_Key; IV: Init_Vector; Op: Operation) return Output_Buffer;
function AES_CBC_192(Input: Input_Buffer; K: AES_192_Key; IV: Init_Vector; Op: Operation) return Output_Buffer;
function AES_CBC_256(Input: Input_Buffer; K: AES_256_Key; IV: Init_Vector; Op: Operation) return Output_Buffer;
```

The `AES.Util` package provides methods for converting between hexadecimal strings and byte arrays. 
```ada
function Hex_To_Bytes(Hex: String) return Bytes;
function Byte_To_Hex(B: Byte) return String;
function Bytes_To_Hex(Bs: Bytes) return String;
```

## Usage
Encrypt a single block with a 128-bit key
```ada
with AES; use AES;
with AES.Util; use AES.Util;
with Ada.Text_IO; use Ada.Text_IO;

procedure Example is
    Input: Block_Bytes := Hex_To_Bytes("00112233445566778899aabbccddeeff");
    Key: AES_128_Key := Hex_To_Bytes("000102030405060708090a0b0c0d0e0f");
    Result: Block_Bytes := AES_Block_128(Input, Key, Encrypt);
begin
    Put_Line(Bytes_To_Hex(Result)); -- 69c4e0d86a7b0430d8cdb78070b4c55a
end Example;
```

Encrypt several blocks in CBC mode with a 192-bit key
```ada
with AES; use AES;
with AES.Util; use AES.Util;
with Ada.Text_IO; use Ada.Text_IO;

procedure Example is
    Input: Input_Buffer := Hex_To_Bytes("f869e8239606a44343f8627cc29a683bd0f431ab80f7121a1a74cb9056d614c5");
    Key: AES_192_Key := Hex_To_Bytes("8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b");
    IV: Init_Vector := Hex_To_Bytes("00112233445566778899AABBCCDDEEFF");
    Result: Output_Buffer := AES_CBC_192(Input, Key, IV, Encrypt);
begin
    -- 7162fa4e6f8b0aacaa28051a3c6983540e6070509aa148d8c733f824649f5183c12fd81c5f3652df2be23f3985c85f53
    Put_Line(Bytes_To_Hex(Result));
end Example;
```

Decrypt a single block with a 256-bit key
```ada
with AES; use AES;
with AES.Util; use AES.Util;
with Ada.Text_IO; use Ada.Text_IO;

procedure Example is
    Input: Block_Bytes := Hex_To_Bytes("8ea2b7ca516745bfeafc49904b496089");
    Key: AES_256_Key := Hex_To_Bytes("000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f");
    Result: Block_Bytes := AES_Block_256(Input, Key, Decrypt);
begin
    Put_Line(Bytes_To_Hex(Result)); -- 00112233445566778899aabbccddeeff
end Example;
```

## Build and test
Clone the repository and run either `gnatmake -D build main.adb` or `gprbuild`. To run the tests, run `./build/main` for Linux/Mac or `.\build\main.exe` for Windows.

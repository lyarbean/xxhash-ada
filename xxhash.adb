package body  xxhash is
   function rotate_left (value : word; amount : Natural) return word;
   pragma import (intrinsic, rotate_left);
   function shift_right (value : word; amount : Natural) return word;
   pragma import (intrinsic, Shift_right);

   type quat is array (1..4) of word;
   prime : constant array (1..5) of word := (2654435761, 2246822519, 3266489917, 668265263, 374761393);

   -- __builtin_bswap32
   function xxh32(data : bytes; seed : word) return word is
      h32 : word := 0;
      r,s : integer := 0;
   begin
      r := data'length / 16;
      if r < 1 then
         h32 := seed + prime(5);
      else
         declare
            v : quat := (seed + prime(1) + prime (2), seed + prime (2), seed, seed - prime(1));
            data_1 : array (1..r) of quat;
            for data_1'address use data(data'first..data'first+16*r-1)'address;
         begin
            -- Pragma Loop_Optimize;
            for q of data_1 loop
               --  for j in v'range loop
               --  v(j) := v(j) +  q(j) * prime(2);
               --  v(j) := rotate_left(v(j), 13) * prime(1);
               --  Unrolled manually
               v(1) := v(1) +  q(1) * prime(2);
               v(1) := rotate_left(v(1), 13) * prime(1);
               v(2) := v(2) +  q(2) * prime(2);
               v(2) := rotate_left(v(2), 13) * prime(1);
               v(3) := v(3) +  q(3) * prime(2);
               v(3) := rotate_left(v(3), 13) * prime(1);
               v(4) := v(4) +  q(4) * prime(2);
               v(4) := rotate_left(v(4), 13) * prime(1);
               --  end loop;
            end loop;

            v(1) := rotate_left(v(1), 1) + rotate_left(v(2), 7);
            v(3) := rotate_left(v(3), 12) + rotate_left(v(4), 18);
            h32  := v(1) + v(3);
         end;
      end if;
      -- there are no more than 16 bytes left, processing them
      h32 := h32 + word(data'length);
      s := data'length rem 16;
      if s /= 0 then
         s := s / 4;
         r := r * 16;
         declare
            data_2 : array (1..s) of word;
            for data_2'address use data(r+1..r+s)'address;
         begin
            for q of data_2 loop
               h32 := h32 + q * prime(3);
               h32 := rotate_left(h32, 17) * prime(4);
            end loop;
         end;
         if data'length - s * 4 > 0 then
            r := r + 4 * s + 1;
            for i in r .. data'last loop
               h32 := h32 + word(data(i)) * prime(5);
               h32 := rotate_left(h32,11) * prime(1);
            end loop;
         end if;
      end if;
      h32 := h32 xor shift_right(h32,15);
      h32 := h32 * prime(2);
      h32 := h32 xor shift_right(h32,13);
      h32 := h32 * prime(3);
      h32 := h32 xor shift_right(h32,16);
      return h32;
   end xxh32;
end xxhash;

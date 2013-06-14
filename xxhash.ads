package xxhash is
   pragma elaborate_body;
   type byte is mod 2**8;
   type bytes is array(natural range<>) of byte;
   type word is mod 2**32;
   function xxh32(data : bytes; seed : word) return word;
end xxhash;

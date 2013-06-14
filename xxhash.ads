with interfaces;
use interfaces;
--  pragma Elaborate_All;
package xxhash is
   type bytes is array(natural range<>) of unsigned_8;
   function xxh32(data : bytes; seed : unsigned_32) return unsigned_32;
end xxhash;

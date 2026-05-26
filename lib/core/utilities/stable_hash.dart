/// Stable deterministic string-to-integer hashing function.
/// Maps alphanumeric remote IDs to local SQLite-compatible integer IDs.
int getStableHashCode(String value) {
  int hash = 0;
  for (int i = 0; i < value.length; i++) {
    hash = (31 * hash + value.codeUnitAt(i)) & 0x7FFFFFFF;
  }
  return hash;
}

//Wrapper for Ints
class Integer {
  int _value = 0;
  Integer(this._value);

  set setValue(int input) => _value = input;
  get value => _value;
}
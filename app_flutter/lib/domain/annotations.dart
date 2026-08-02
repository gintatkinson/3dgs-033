/// Marks a Dart class as realising a UML schema type.
///
/// The [value] names the UML schema element in the form
/// `UML::ClassName.member`.
class realizes {
  final String value;
  const realizes(this.value);
}

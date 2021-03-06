// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analysis_server/src/services/correction/fix.dart';
import 'package:analyzer/src/dart/analysis/experiments.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'fix_processor.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(QualifyReferenceTest);
    defineReflectiveTests(QualifyReferenceWithExtensionMethodsTest);
  });
}

@reflectiveTest
class QualifyReferenceTest extends FixProcessorTest {
  @override
  FixKind get kind => DartFixKind.QUALIFY_REFERENCE;

  test_class_direct() async {
    await resolveTestUnit('''
class C {
  static void m() {}
}
class D extends C {
  void f() {
    m();
  }
}
''');
    await assertHasFix('''
class C {
  static void m() {}
}
class D extends C {
  void f() {
    C.m();
  }
}
''');
  }

  test_class_imported() async {
    newFile('/home/test/lib/a.dart', content: '''
class A {
  static void m() {}
}
''');
    await resolveTestUnit('''
import 'a.dart';
class B extends A {
  void f() {
    m();
  }
}
''');
    await assertNoFix();
  }

  test_class_importedWithPrefix() async {
    newFile('/home/test/lib/a.dart', content: '''
class A {
  static void m() {}
}
''');
    await resolveTestUnit('''
import 'a.dart' as a;
class B extends a.A {
  void f() {
    m();
  }
}
''');
    await assertNoFix();
  }

  test_class_indirect() async {
    await resolveTestUnit('''
class A {
  static void m() {}
}
class B extends A {}
class C extends B {}
class D extends C {
  void f() {
    m();
  }
}
''');
    await assertHasFix('''
class A {
  static void m() {}
}
class B extends A {}
class C extends B {}
class D extends C {
  void f() {
    A.m();
  }
}
''');
  }

  test_class_notImported() async {
    newFile('/home/test/lib/a.dart', content: '''
class A {
  static void m() {}
}
''');
    newFile('/home/test/lib/b.dart', content: '''
import 'a.dart';
class B extends A {}
''');
    await resolveTestUnit('''
import 'b.dart';
class C extends B {
  void f() {
    m();
  }
}
''');
    await assertNoFix();
  }
}

@reflectiveTest
class QualifyReferenceWithExtensionMethodsTest extends QualifyReferenceTest {
  @override
  void setupResourceProvider() {
    super.setupResourceProvider();
    createAnalysisOptionsFile(experiments: [EnableString.extension_methods]);
  }

  test_extension_direct() async {
    await resolveTestUnit('''
class C {
  static void m() {}
}
extension E on C {
  void f() {
    m();
  }
}
''');
    await assertHasFix('''
class C {
  static void m() {}
}
extension E on C {
  void f() {
    C.m();
  }
}
''');
  }

  test_extension_imported() async {
    newFile('/home/test/lib/a.dart', content: '''
class A {
  static void m() {}
}
''');
    await resolveTestUnit('''
import 'a.dart';
extension E on A {
  void f() {
    m();
  }
}
''');
    await assertNoFix();
  }

  test_extension_importedWithPrefix() async {
    newFile('/home/test/lib/a.dart', content: '''
class A {
  static void m() {}
}
''');
    await resolveTestUnit('''
import 'a.dart' as a;
extension E on a.A {
  void f() {
    m();
  }
}
''');
    await assertNoFix();
  }

  test_extension_indirect() async {
    await resolveTestUnit('''
class A {
  static void m() {}
}
class B extends A {}
class C extends B {}
extension E on C {
  void f() {
    m();
  }
}
''');
    await assertHasFix('''
class A {
  static void m() {}
}
class B extends A {}
class C extends B {}
extension E on C {
  void f() {
    A.m();
  }
}
''');
  }

  test_extension_notImported() async {
    newFile('/home/test/lib/a.dart', content: '''
class A {
  static void m() {}
}
''');
    newFile('/home/test/lib/b.dart', content: '''
import 'a.dart';
class B extends A {}
''');
    await resolveTestUnit('''
import 'b.dart';
extension E on B {
  void f() {
    m();
  }
}
''');
    await assertNoFix();
  }
}

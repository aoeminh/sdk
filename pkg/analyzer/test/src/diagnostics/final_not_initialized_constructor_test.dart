// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/src/error/codes.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../dart/resolution/driver_resolution.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(FinalNotInitializedConstructorTest);
  });
}

@reflectiveTest
class FinalNotInitializedConstructorTest extends DriverResolutionTest {
  test_1() async {
    await assertErrorsInCode('''
class A {
  final int x;
  A() {}
}
''', [
      error(StaticWarningCode.FINAL_NOT_INITIALIZED_CONSTRUCTOR_1, 27, 1),
    ]);
  }

  test_2() async {
    await assertErrorsInCode('''
class A {
  final int a;
  final int b;
  A() {}
}
''', [
      error(StaticWarningCode.FINAL_NOT_INITIALIZED_CONSTRUCTOR_2, 42, 1),
    ]);
  }

  test_3Plus() async {
    await assertErrorsInCode('''
class A {
  final int a;
  final int b;
  final int c;
  A() {}
}
''', [
      error(StaticWarningCode.FINAL_NOT_INITIALIZED_CONSTRUCTOR_3_PLUS, 57, 1),
    ]);
  }
}

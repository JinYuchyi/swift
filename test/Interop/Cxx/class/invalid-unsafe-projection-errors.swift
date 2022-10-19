// RUN: rm -rf %t
// RUN: split-file %s %t
// RUN: not %target-swift-frontend -typecheck -I %t/Inputs  %t/test.swift  -enable-experimental-cxx-interop 2>&1 | %FileCheck %s

//--- Inputs/module.modulemap
module Test {
    header "test.h"
    requires cplusplus
}

//--- Inputs/test.h
struct Ptr { int *p; };

struct M {
        int *test1() const;
        int &test2() const;
        Ptr test3() const;

        int *begin() const;
};

//--- test.swift

import Test

public func test(x: M) {
  // CHECK: note: C++ method 'test1' that returns unsafe projection of type 'pointer' not imported
  x.test1()
  // CHECK: note: C++ method 'test2' that returns unsafe projection of type 'reference' not imported
  x.test2()
  // CHECK: note: C++ method 'test3' that returns unsafe projection of type 'Ptr' not imported
  x.test3()
  // CHECK: error: value of type 'M' has no member 'begin'
  // CHECK: error: 'begin' is unavailable in Swift as it returns a C++ iterator. Use 'for-in' loop or 'Sequence' methods such as 'map', 'reduce' to iterate over the collection.
  x.begin()
}
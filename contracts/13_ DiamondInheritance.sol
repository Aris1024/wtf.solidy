// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

/* 继承树：
  God
 /  \
Adam Eve
 \  /
people
*/
contract God {
    event Log(string msg);

    function foo() public virtual {
        emit Log("God.foo called");
    }

    function bar() public virtual {
        emit Log("God.bar called");
    }
}

contract Adam is God {
    function foo() public virtual override {
        emit Log("Adam.foo called");
        super.foo();
    }

    function bar() public virtual override {
        emit Log("Adam.bar called");
        super.bar();
    }
}

contract Eva is God {
    function foo() public virtual override {
        emit Log("Eva.foo called");
        super.foo();
    }

    function bar() public virtual override {
        emit Log("Eva.bar called");
        super.bar();
    }
}

contract People is Adam, Eva {
    function foo() public virtual override(Adam, Eva) {
        super.foo();
    }

    function bar() public virtual override(Adam, Eva) {
        super.bar();
    }
}

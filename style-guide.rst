编程风格指南

概述

本指南旨在约定 solidity 代码的编码规范。本指南是不断变化演进的，旧的、过时的编码规范会被淘汰， 而新的、有用的规范会被添加进来。

许多项目会实施他们自己的编码风格指南。如遇冲突，应优先使用具体项目的风格指南。

本风格指南中的结构和许多建议是取自 python 的 pep8 style guide 。

本指南并 不是 以指导正确或最佳的 solidity 编码方式为目的。本指南的目的是保持代码的 一致性 。 来自 python 的参考文档 pep8 。很好地阐述了这个概念。

Note

风格指南是关于一致性的。重要的是与此风格指南保持一致。但项目中的一致性更重要。一个模块或功能内的一致性是最重要的。

但最重要的是：知道什么时候不一致 —— 有时风格指南不适用。如有疑问，请自行判断。看看其他例子，并决定什么看起来最好。并应毫不犹豫地询问他人！

代码结构

缩进

每个缩进级别使用4个空格。

制表符或空格

空格是首选的缩进方法。

应该避免混合使用制表符和空格。

空行

在 solidity 源码中合约声明之间留出两个空行。

正确写法:

contract A {
    ...
}


contract B {
    ...
}


contract C {
    ...
}
错误写法:

contract A {
    ...
}
contract B {
    ...
}

contract C {
    ...
}
在一个合约中的函数声明之间留有一个空行。

在相关联的各组单行语句之间可以省略空行。（例如抽象合约的 stub 函数）。

正确写法:

pragma solidity ^0.8.0;

abstract contract A {
    function spam() public virtual pure;
    function ham() public virtual pure;
}


contract B is A {
    function spam() public pure override {
        // ...
    }

    function ham() public pure override {
        // ...
    }
}
错误写法:

pragma solidity >=0.4.0 <0.9.0;

abstract contract A {
    function spam() virtual pure public;
    function ham() public virtual pure;
}


contract B is A {
    function spam() public pure override {
        // ...
    }
    function ham() public pure override {
        // ...
    }
}
代码行的最大长度

基于 PEP 8 recommendation ，将代码行的字符长度控制在 79（或 99）字符来帮助读者阅读代码。

折行时应该遵从以下指引：

第一个参数不应该紧跟在左括号后边
用一个、且只用一个缩进
每个函数应该单起一行
结束符号 ); 应该单独放在最后一行
函数调用

Yes:

thisFunctionCallIsReallyLong(
    longArgument1,
    longArgument2,
    longArgument3
);
No:

thisFunctionCallIsReallyLong(longArgument1,
                              longArgument2,
                              longArgument3
);

thisFunctionCallIsReallyLong(longArgument1,
    longArgument2,
    longArgument3
);

thisFunctionCallIsReallyLong(
    longArgument1, longArgument2,
    longArgument3
);

thisFunctionCallIsReallyLong(
longArgument1,
longArgument2,
longArgument3
);

thisFunctionCallIsReallyLong(
    longArgument1,
    longArgument2,
    longArgument3);
赋值语句

Yes:

thisIsALongNestedMapping[being][set][to_some_value] = someFunction(
    argument1,
    argument2,
    argument3,
    argument4
);
No:

thisIsALongNestedMapping[being][set][to_some_value] = someFunction(argument1,
                                                                   argument2,
                                                                   argument3,
                                                                   argument4);
事件定义和事件发生

Yes:

event LongAndLotsOfArgs(
    adress sender,
    adress recipient,
    uint256 publicKey,
    uint256 amount,
    bytes32[] options
);

LongAndLotsOfArgs(
    sender,
    recipient,
    publicKey,
    amount,
    options
);
No:

event LongAndLotsOfArgs(adress sender,
                        adress recipient,
                        uint256 publicKey,
                        uint256 amount,
                        bytes32[] options);

LongAndLotsOfArgs(sender,
                  recipient,
                  publicKey,
                  amount,
                  options);
源文件编码格式

首选 UTF-8 或 ASCII 编码。

Imports 规范

Import 语句应始终放在文件的顶部。

正确写法:

import "owned";


contract A {
    ...
}


contract B is owned {
    ...
}
错误写法:

contract A {
    ...
}


import "owned";


contract B is owned {
    ...
}
函数顺序

排序有助于读者识别他们可以调用哪些函数，并更容易地找到构造函数和 fallback 函数的定义。

函数应根据其可见性和顺序进行分组：

构造函数
receive 函数（如果存在）
fallback 函数（如果存在）
外部函数(external)
公共函数(public)
内部(internal)
私有(private)
在一个分组中，把 view 和 pure 函数放在最后。

正确写法:

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
contract A {
    function A() public {
        ...
    }

    receive() external payable {
        // ...
    }

    fallback() external {
        // ...
    }

    // External functions
    // ...

    // External functions that are view
    // ...

    // External functions that are pure
    // ...

    // Public functions
    // ...

    // Internal functions
    // ...

    // Private functions
    // ...
}
错误写法:

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
contract A {

    // External functions
    // ...


    fallback() external {
        // ...
    }
    receive() external payable {
        // ...
    }

    // Private functions
    // ...

    // Public functions
    // ...

    function A() public {
        ...
    }

    function() public {
        ...
    }

    // Internal functions
    // ...
}
表达式中的空格

在以下情况下避免无关的空格：

除单行函数声明外，紧接着小括号，中括号或者大括号的内容应该避免使用空格。

正确写法:

spam(ham[1], Coin({name: "ham"}));
错误写法:

spam( ham[ 1 ], Coin( { name: "ham" } ) );
除外:

function singleLine() public { spam(); }
紧接在逗号，分号之前：

正确写法:

function spam(uint i, Coin coin) public;
错误写法:

function spam(uint i , Coin coin) public ;
赋值或其他操作符两边多于一个的空格：

正确写法:

x = 1;
y = 2;
long_variable = 3;
错误写法:

x             = 1;
y             = 2;
long_variable = 3;
fallback 和 receive 函数中不要包含空格：

正确写法::
receive() external payable {
...
}

function() public {
...
}

错误写法:

receive () external payable {
    ...
}

function () public {
    ...
}
控制结构

用大括号表示一个合约，库、函数和结构。 应该：

开括号与声明应在同一行。
闭括号在与之前函数声明对应的开括号保持同一缩进级别上另起一行。
开括号前应该有一个空格。
正确写法:

contract Coin {
    struct Bank {
        address owner;
        uint balance;
    }
}
错误写法:

contract Coin
{
    struct Bank {
        address owner;
        uint balance;
    }
}
对于控制结构 if， else， while， for 的实施建议与以上相同。

另外，诸如 if， else， while， for 这类的控制结构和条件表达式的块之间应该有一个单独的空格， 同样的，条件表达式的块和开括号之间也应该有一个空格。

正确写法:

if (...) {
    ...
}

for (...) {
    ...
}
错误写法:

if (...)
{
    ...
}

while(...){
}

for (...) {
    ...;}
对于控制结构， 如果 其主体内容只包含一行，则可以省略括号。

正确写法:

if (x < 10)
    x += 1;
错误写法:

if (x < 10)
    someArray.push(Coin({
        name: 'spam',
        value: 42
    }));
对于具有 else 或 else if 子句的 if 块， else 应该是与 if 的闭大括号放在同一行上。 这一规则区别于 其他块状结构。

正确写法:

if (x < 3) {
    x += 1;
} else if (x > 7) {
    x -= 1;
} else {
    x = 5;
}


if (x < 3)
    x += 1;
else
    x -= 1;
错误写法:

if (x < 3) {
    x += 1;
}
else {
    x -= 1;
}
函数声明

对于简短的函数声明，建议函数体的开括号与函数声明保持在同一行。

闭大括号应该与函数声明的缩进级别相同。

开大括号之前应该有一个空格。

正确写法:

function increment(uint x) public pure returns (uint) {
    return x + 1;
}

function increment(uint x) public pure onlyowner returns (uint) {
    return x + 1;
}
错误写法:

function increment(uint x) public pure returns (uint)
{
    return x + 1;
}

function increment(uint x) public pure returns (uint){
    return x + 1;
}

function increment(uint x) public pure returns (uint) {
    return x + 1;
    }

function increment(uint x) public pure returns (uint) {
    return x + 1;}
你应该严格地标示所有函数的可见性，包括构造函数。

Yes:

function explicitlyPublic(uint val) public {
    doSomething();
}
No:

function implicitlyPublic(uint val) {
    doSomething();
}
函数修改器的顺序应该是:

Visibility
Mutability
Virtual
Override
Custom modifiers
Yes:

function balance(uint from) public view override returns (uint)  {
    return balanceOf[from];
}

function shutdown() public onlyowner {
    selfdestruct(owner);
}
No:

function balance(uint from) public override view returns (uint)  {
    return balanceOf[from];
}

function shutdown() onlyowner public {
    selfdestruct(owner);
}
对于长函数声明，建议将每个参数独立一行并与函数体保持相同的缩进级别。闭括号和开括号也应该 独立一行并保持与函数声明相同的缩进级别。

正确写法:

function thisFunctionHasLotsOfArguments(
    address a,
    address b,
    address c,
    address d,
    address e,
    address f
)
    public
{
    doSomething();
}
错误写法:

function thisFunctionHasLotsOfArguments(address a, address b, address c,
    address d, address e, address f) public {
    doSomething();
}

function thisFunctionHasLotsOfArguments(address a,
                                        address b,
                                        address c,
                                        address d,
                                        address e,
                                        address f) public {
    doSomething();
}

function thisFunctionHasLotsOfArguments(
    address a,
    address b,
    address c,
    address d,
    address e,
    address f) public {
    doSomething();
}
如果一个长函数声明有修饰符，那么每个修饰符应该下沉到独立的一行。

正确写法:

function thisFunctionNameIsReallyLong(address x, address y, address z)
    public
    onlyowner
    priced
    returns (address)
{
    doSomething();
}

function thisFunctionNameIsReallyLong(
    address x,
    address y,
    address z,
)
    public
    onlyowner
    priced
    returns (address)
{
    doSomething();
}
错误写法:

function thisFunctionNameIsReallyLong(address x, address y, address z)
                                      public
                                      onlyowner
                                      priced
                                      returns (address) {
    doSomething();
}

function thisFunctionNameIsReallyLong(address x, address y, address z)
    public onlyowner priced returns (address)
{
    doSomething();
}

function thisFunctionNameIsReallyLong(address x, address y, address z)
    public
    onlyowner
    priced
    returns (address) {
    doSomething();
}
多行输出参数和返回值语句应该遵从 :ref:`代码行的最大长度 <maximum_line_length>` 一节的说明。

Yes:

function thisFunctionNameIsReallyLong(
    address a,
    address b,
    address c
)
    public
    returns (
        address someAddressName,
        uint256 LongArgument,
        uint256 Argument
    )
{
    doSomething()

    return (
        veryLongReturnArg1,
        veryLongReturnArg2,
        veryLongReturnArg3
    );
}
No:

function thisFunctionNameIsReallyLong(
    address a,
    address b,
    address c
)
    public
    returns (address someAddressName,
             uint256 LongArgument,
             uint256 Argument)
{
    doSomething()

    return (veryLongReturnArg1,
            veryLongReturnArg1,
            veryLongReturnArg1);
}
对于继承合约中需要参数的构造函数，如果函数声明很长或难以阅读，建议将基础构造函数像多个修饰符的风格那样 每个下沉到一个新行上书写。

正确写法:

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.0;

// Base contracts just to make this compile
contract B {
    constructor(uint) {
    }
}
contract C {
    constructor(uint, uint) {
    }
}
contract D {
    constructor(uint) {
    }
}

contract A is B, C, D {
    uint x;

    constructor(uint param1, uint param2, uint param3, uint param4, uint param5)
        B(param1)
        C(param2, param3)
        D(param4)
    {
        // do something with param5
        x = param5;
    }
}
错误写法:

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;


// Base contracts just to make this compile
contract B {
    constructor(uint) {
    }
}


contract C {
    constructor(uint, uint) {
    }
}


contract D {
    constructor(uint) {
    }
}


contract A is B, C, D {
    uint x;

    constructor(uint param1, uint param2, uint param3, uint param4, uint param5)
    B(param1)
    C(param2, param3)
    D(param4)
    public {
        x = param5;
    }
}


contract X is B, C, D {
    uint x;

    constructor(uint param1, uint param2, uint param3, uint param4, uint param5)
        B(param1)
        C(param2, param3)
        D(param4)
        public {
            x = param5;
        }
}
当用单个语句声明简短函数时，允许在一行中完成。

允许:

function shortFunction() public { doSomething(); }
这些函数声明的准则旨在提高可读性。 因为本指南不会涵盖所有内容，作者应该自行作出最佳判断。

映射

In variable declarations, do not separate the keyword mapping from its type by a space. Do not separate any nested mapping keyword from its type by whitespace.

Yes:

mapping(uint => uint) map;
mapping(address => bool) registeredAddresses;
mapping(uint => mapping(bool => Data[])) public data;
mapping(uint => mapping(uint => s)) data;
No:

mapping (uint => uint) map;
mapping( address => bool ) registeredAddresses;
mapping (uint => mapping (bool => Data[])) public data;
mapping(uint => mapping (uint => s)) data;
变量声明

数组变量的声明在变量类型和括号之间不应该有空格。

正确写法:

uint[] x;
错误写法:

uint [] x;
其他建议

字符串应该用双引号而不是单引号。
正确写法:

str = "foo";
str = "Hamlet says, 'To be or not to be...'";
错误写法:

str = 'bar';
str = '"Be yourself; everyone else is already taken." -Oscar Wilde';
操作符两边应该各有一个空格。
正确写法:

x = 3;
x = 100 / 10;
x += 3 + 4;
x |= y && z;
错误写法:

x=3;
x = 100/10;
x += 3+4;
x |= y&&z;
为了表示优先级，高优先级操作符两边可以省略空格。这样可以提高复杂语句的可读性。你应该在操作符两边总是使用相同的空格数：
正确写法:

x = 2**3 + 5;
x = 2*y + 3*z;
x = (a+b) * (a-b);
错误写法:

x = 2** 3 + 5;
x = y+z;
x +=1;
Order of Layout

Layout contract elements in the following order:

Pragma statements
Import statements
Interfaces
Libraries
Contracts
Inside each contract, library or interface, use the following order:

Type declarations
State variables
Events
Functions
Note

It might be clearer to declare types close to their use in events or state variables.

命名规范

当完全采纳和使用命名规范时会产生强大的作用。 当使用不同的规范时，则不会立即获取代码中传达的重要 元 信息。

这里给出的命名建议旨在提高可读性，因此它们不是规则，而是透过名称来尝试和帮助传达最多的信息。

最后，基于代码库中的一致性，本文档中的任何规范总是可以被（代码库中的规范）取代。

命名风格

为了避免混淆，下面的名字用来指明不同的命名方式。

b (单个小写字母)
B (单个大写字母)
lowercase （小写）
lower_case_with_underscores （小写和下划线）
UPPERCASE （大写）
UPPER_CASE_WITH_UNDERSCORES （大写和下划线）
CapitalizedWords (驼峰式，首字母大写）
mixedCase (混合式，与驼峰式的区别在于首字母小写！)
Capitalized_Words_With_Underscores (首字母大写和下划线)
..note:: 当在驼峰式命名中使用缩写时，应该将缩写中的所有字母都大写。 因此 HTTPServerError 比 HttpServerError 好。
当在混合式命名中使用缩写时，除了第一个缩写中的字母小写（如果它是整个名称的开头的话）以外，其他缩写中的字母均大写。 因此 xmlHTTPRequest 比 XMLHTTPRequest 更好。
应避免的名称

l - el的小写方式
O - oh的大写方式
I - eye的大写方式
切勿将任何这些用于单个字母的变量名称。 他们经常难以与数字 1 和 0 区分开。

合约和库名称

合约和库名称应该使用驼峰式风格。比如：SimpleToken，SmartBank，CertificateHashRepository，Player，Congress, Owned。 * Contract and library names should also match their filenames. * If a contract file includes multiple contracts and/or libraries, then the filename should match the core contract. This is not recommended however if it can be avoided.

As shown in the example below, if the contract name is Congress and the library name is Owned, then their associated filenames should be Congress.sol and Owned.sol.

Yes:

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.0;


// Owned.sol
contract Owned {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}
and in Congress.sol:

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;

import "./Owned.sol";


contract Congress is Owned, TokenRecipient {
    //...
}
No:

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.0;


// owned.sol
contract owned {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}
and in Congress.sol:

import "./owned.sol";


contract Congress is owned, tokenRecipient {
    //...
}
结构体名称

结构体名称应该使用驼峰式风格。比如：MyCoin，Position，PositionXY。

事件名称

事件名称应该使用驼峰式风格。比如：Deposit，Transfer，Approval，BeforeTransfer，AfterTransfer。

函数名称

函数应该使用混合式命名风格。比如：getBalance，transfer，verifyOwner，addMember，changeOwner。

函数参数命名

函数参数命名应该使用混合式命名风格。比如：initialSupply，account，recipientAddress，senderAddress，newOwner。 在编写操作自定义结构的库函数时，这个结构体应该作为函数的第一个参数，并且应该始终命名为 self。

局部变量和状态变量名称

使用混合式命名风格。比如：totalSupply，remainingSupply，balancesOf，creatorAddress，isPreSale，tokenExchangeRate。

常量命名

常量应该全都使用大写字母书写，并用下划线分割单词。比如：MAX_BLOCKS，TOKEN_NAME，TOKEN_TICKER，CONTRACT_VERSION。

修饰符命名

使用混合式命名风格。比如：onlyBy，onlyAfter，onlyDuringThePreSale。

枚举命名

在声明简单类型时，枚举应该使用驼峰式风格。比如：TokenGroup，Frame，HashStyle，CharacterLocation。

避免命名冲突

single_trailing_underscore_
当所起名称与内建或保留关键字相冲突时，建议照此惯例在名称后边添加下划线。

描述注释 NatSpec

Solidity 智能合约有一种基于以太坊自然语言说明格式（Ethereum Natural Language Specification Format）的注释形式。

Add comments above functions or contracts following doxygen notation of one or multiple lines starting with /// or a multiline comment starting with /** and ending with */.

For example, the contract from :ref:`a simple smart contract <simple-smart-contract>`_ with the comments added looks like the one below:

pragma solidity >=0.4.16 <0.9.0;

/// @author The Solidity Team
/// @title A simple storage example
contract TinyStorage {
    uint storedData;

    /// Store `x`.
    /// @param x the new value to store
    /// @dev stores the number in the state variable `storedData`
    function set(uint x) public {
        storedData = x;
    }

    /// Return the stored value.
    /// @dev retrieves the value of the state variable `storedData`
    /// @return the stored value
    function get() public view returns (uint) {
        return storedData;
    }
}
It is recommended that Solidity contracts are fully annontated using :ref:`NatSpec <natspec>`_ for all public interfaces (everything in the ABI).

Please see the sectian about :ref:`NatSpec <natspec>`_ for a detailed explanation.
//===- FIRRTLOpInterfaces.td - Operation Interfaces --------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This describes the FIRRTL operation interfaces.
//
//===----------------------------------------------------------------------===//

#ifndef CIRCT_DIALECT_FIRRTL_FIRRTLOPINTERFACES_TD
#define CIRCT_DIALECT_FIRRTL_FIRRTLOPINTERFACES_TD

include "mlir/IR/OpBase.td"

def FModuleLike : OpInterface<"FModuleLike"> {
  let cppNamespace = "circt::firrtl";
  let description = "Provide common module information.";
  let methods = [

    //===------------------------------------------------------------------===//
    // Module Name
    //===------------------------------------------------------------------===//

    InterfaceMethod<"Get the module name",
    "StringRef", "moduleName", (ins),
    /*methodBody=*/[{ return $_op.getName(); }]>,

    InterfaceMethod<"Get the module name",
    "StringAttr", "moduleNameAttr", (ins),
    /*methodBody=*/[{ return $_op.getNameAttr(); }]>,

    //===------------------------------------------------------------------===//
    // Port Directions
    //===------------------------------------------------------------------===//

    InterfaceMethod<"Get the port directions attribute",
    "IntegerAttr", "getPortDirectionsAttr", (ins), [{}],
    /*defaultImplementation=*/[{
      return $_op->template
        getAttrOfType<IntegerAttr>(FModuleLike::getPortDirectionsAttrName());
    }]>,

    InterfaceMethod<"Get the port directions",
    "APInt", "getPortDirections", (ins), [{}],
    /*defaultImplementation=*/[{
      return $_op.getPortDirectionsAttr().getValue();
    }]>,

    InterfaceMethod<"Get a port direction",
    "Direction", "getPortDirection", (ins "size_t":$portIndex), [{}],
    /*defaultImplementation=*/[{
      return direction::get($_op.getPortDirections()[portIndex]);
    }]>,

    //===------------------------------------------------------------------===//
    // Port Names
    //===------------------------------------------------------------------===//

    InterfaceMethod<"Get the port names attribute",
    "ArrayAttr", "getPortNamesAttr", (ins), [{}],
    /*defaultImplementation=*/[{
      return $_op->template
        getAttrOfType<ArrayAttr>(FModuleLike::getPortNamesAttrName());
    }]>,

    InterfaceMethod<"Get the port names",
    "ArrayRef<Attribute>", "getPortNames", (ins), [{}],
    /*defaultImplementation=*/[{
      return $_op.getPortNamesAttr().getValue();
    }]>,

    InterfaceMethod<"Get a port name",
    "StringAttr", "getPortNameAttr", (ins "size_t":$portIndex), [{}],
    /*defaultImplementation=*/[{
      return $_op.getPortNames()[portIndex].template cast<StringAttr>();
    }]>,

    InterfaceMethod<"Get a port name",
    "StringRef", "getPortName", (ins "size_t":$portIndex), [{}],
    /*defaultImplementation=*/[{
      return $_op.getPortNameAttr(portIndex).getValue();
    }]>,

    //===------------------------------------------------------------------===//
    // Port Types
    //===------------------------------------------------------------------===//

    InterfaceMethod<"Get the port types attribute",
    "ArrayAttr", "getPortTypesAttr", (ins), [{}],
    /*defaultImplementation=*/[{
      return $_op->template
        getAttrOfType<ArrayAttr>(FModuleLike::getPortTypesAttrName());
    }]>,

    InterfaceMethod<"Get the port types",
    "ArrayRef<Attribute>", "getPortTypes", (ins), [{}],
    /*defaultImplementation=*/[{
      return $_op.getPortTypesAttr().getValue();
    }]>,

    InterfaceMethod<"Get a port type",
    "TypeAttr", "getPortTypeAttr", (ins "size_t":$portIndex), [{}],
    /*defaultImplementation=*/[{
      return $_op.getPortTypes()[portIndex].template cast<TypeAttr>();
    }]>,

    InterfaceMethod<"Get a port type",
    "Type", "getPortType", (ins "size_t":$portIndex), [{}],
    /*defaultImplementation=*/[{
      auto typeAttr = $_op.getPortTypeAttr(portIndex);
      return typeAttr.getValue();
    }]>,

    //===------------------------------------------------------------------===//
    // Port Annotations
    //===------------------------------------------------------------------===//

    InterfaceMethod<"Get the port annotations attribute",
    "ArrayAttr", "getPortAnnotationsAttr", (ins), [{}],
    /*defaultImplementation=*/[{
      return $_op->template
        getAttrOfType<ArrayAttr>(FModuleLike::getPortAnnotationsAttrName());
    }]>,

    InterfaceMethod<"Get the port annotations attribute",
    "ArrayRef<Attribute>", "getPortAnnotations", (ins), [{}],
    /*defaultImplementation=*/[{
      return $_op.getPortAnnotationsAttr().getValue();
    }]>,

    InterfaceMethod<"Get a port's annotations attribute",
    "ArrayAttr", "getAnnotationsAttrForPort", (ins "size_t":$portIndex), [{}],
    /*defaultImplementation=*/[{
      auto annos = $_op.getPortAnnotationsAttr();
      if (annos.empty())
        return annos; // annos already is an empty array
      return annos[portIndex].template cast<ArrayAttr>();
    }]>,

    InterfaceMethod<"Get a port's annotations",
    "ArrayRef<Attribute>", "getAnnotationsForPort",
    (ins "size_t":$portIndex), [{}],
    /*defaultImplementation=*/[{
      return $_op.getAnnotationsAttrForPort(portIndex).getValue();
    }]>,

    //===------------------------------------------------------------------===//
    // Port Symbols
    //===------------------------------------------------------------------===//
    // Symbol conventions:
    // 1. Every element of the ArrayAttr(portSyms) must be NON-NULL.
    // 2. An empty array represents no symbol.
    //    a. TODO: Update the representation to avoid storing it.
    // 3. The Getters return null if a port sym is invalid.
    // 4. The fixupPortSymsArray, is a utility to update a portSyms
    //    Vector, by replacing each null entry with empty array and
    //    clearing the array if all the elements are empty.

    // Getters
    InterfaceMethod<"Get the port symbols attribute",
    "ArrayAttr", "getPortSymbolsAttr", (ins), [{}], [{
      return $_op->template
        getAttrOfType<ArrayAttr>(FModuleLike::getPortSymbolsAttrName());
    }]>,

    InterfaceMethod<"Get the port symbols",
    "ArrayRef<Attribute>", "getPortSymbols", (ins), [{}], [{
      return $_op.getPortSymbolsAttr().getValue();
    }]>,

    InterfaceMethod<"Check if port has symbol attribute",
    "bool", "hasPortSymbolAttr", (ins "size_t":$portIndex), [{}], [{
      auto syms = $_op.getPortSymbols();
        return  (!syms.empty() &&
        !syms[portIndex].template cast<hw::InnerSymAttr>().empty());
    }]>,

    // Setters
    InterfaceMethod<"Set the port symbols", "void",
    "setPortSymbols", (ins "ArrayRef<Attribute>":$symbols), [{}], [{
      assert(symbols.empty() || symbols.size() == $_op.getNumPorts());
      SmallVector<Attribute> newSyms(symbols.begin(), symbols.end());
      FModuleLike::fixupPortSymsArray(newSyms, $_op.getContext());
      assert(newSyms.empty() || newSyms.size() == $_op.getNumPorts());
      $_op->setAttr(FModuleLike::getPortSymbolsAttrName(),
                    ArrayAttr::get($_op.getContext(), newSyms));
    }]>,

    InterfaceMethod<"Set a port symbol attribute", "void",
    "setPortSymbolAttr", (ins "size_t":$portIndex, "StringAttr":$symbol), [{}],
    [{
      SmallVector<Attribute> symbols($_op.getPortSymbols().begin(),
                                     $_op.getPortSymbols().end());
      if (symbols.empty()) {
        symbols.resize($_op.getNumPorts(),
                      hw::InnerSymAttr::get($_op.getContext()));
      }
      assert(symbols.size() == $_op.getNumPorts());
      symbols[portIndex] = hw::InnerSymAttr::get(symbol);

      FModuleLike::fixupPortSymsArray(symbols, $_op.getContext());
      assert(symbols.empty() || symbols.size() == $_op.getNumPorts());
      $_op->setAttr(FModuleLike::getPortSymbolsAttrName(),
                    ArrayAttr::get($_op.getContext(), symbols));
    }]>,

    InterfaceMethod<"Set a port symbol", "void",
    "setPortSymbol", (ins "size_t":$portIndex, "StringRef":$symbol), [{}], [{
      $_op.setPortSymbolAttr(portIndex, StringAttr::get($_op.getContext(),
        symbol));
    }]>,

    //===------------------------------------------------------------------===//
    // All Port Information
    //===------------------------------------------------------------------===//

    InterfaceMethod<"Get information about all ports",
    "SmallVector<PortInfo>", "getPorts">,

    InterfaceMethod<"Inserts the given ports at the corresponding indices",
    "void", "insertPorts",
    (ins "ArrayRef<std::pair<unsigned, PortInfo>>":$ports)>,

    InterfaceMethod<"Erases the ports that have their corresponding bit set in `portIndices`",
    "void", "erasePorts",
    (ins "const llvm::BitVector&":$portIndices)>
  ];

  let extraClassDeclaration = [{
    /// Get the attribute name for port directions.
    static StringRef getPortDirectionsAttrName() {
      return "portDirections";
    }

    /// Get the attribute name for port names",
    static StringRef getPortNamesAttrName() {
      return "portNames";
    }

    /// Get the attribute name for port types.
    static StringRef getPortTypesAttrName() {
      return "portTypes";
    }

    /// Get the attribute name for port annotations.
    static StringRef getPortAnnotationsAttrName() {
      return "portAnnotations";
    }

    /// Get the attribute name for port symbols.
    static StringRef getPortSymbolsAttrName() {
      return "portSyms";
    }

    /// Replace NULL entries with invalid sym and clear array if all elements
    /// are invalid.
    static void fixupPortSymsArray(SmallVectorImpl<Attribute> &syms,
                                   MLIRContext *context) {
      // The lack of *any* port symbol is represented by an empty `portSyms`
      // array as a shorthand.
      if (llvm::none_of(syms, [&](auto &sym) {
            return sym && !cast<hw::InnerSymAttr>(sym).empty();
          })) {
        syms.clear();
        return;
      }
      auto empty = hw::InnerSymAttr::get(context);
      for (auto &sym : syms)
        if (!sym)
          sym = empty;
    }
  }];

  let verify = [{
    static_assert(
        ConcreteOp::template hasTrait<::mlir::SymbolOpInterface::Trait>(),
        "expected operation to be a symbol");
    static_assert(
        ConcreteOp::template hasTrait<::circt::hw::HWModuleLike::Trait>(),
        "expected operation to be also be a hardware module");
    static_assert(
        ConcreteOp::template hasTrait<OpTrait::InnerSymbolTable>(),
        "expected operation to be an inner symbol table");
    return verifyModuleLikeOpInterface(op);
  }];
}

def FConnectLike : OpInterface<"FConnectLike"> {
  let cppNamespace = "circt::firrtl";
  let description = "Provide common connection information.";

  let methods = [
    InterfaceMethod<"Return a destination of connection.",
    "Value", "getDest", (ins)>,
    InterfaceMethod<"Return a source of connection.",
    "Value", "getSrc", (ins)>,
  ];
}

def FNamableOp : OpInterface<"FNamableOp"> {
  let cppNamespace = "circt::firrtl";
  let description = [{The interface provides common methods for namable operations
    related to name preservation semantics. }];

  let methods = [
    InterfaceMethod<"Return true if the name is droppable.",
    "bool", "hasDroppableName", (ins), [{}], /*defaultImplementation=*/[{
      return this->getOperation()->template
             getAttrOfType<NameKindEnumAttr>("nameKind").getValue()
             == NameKindEnum::DroppableName;
    }]>,
    InterfaceMethod<"Make the name droppable.",
    "void", "dropName", (ins), [{}], /*defaultImplementation=*/[{
      this->getOperation()->setAttr("nameKind",
        NameKindEnumAttr::get(this->getOperation()->getContext(),
                              NameKindEnum::DroppableName));
    }]>,
    InterfaceMethod<"Set a namekind.",
    "void", "setNameKindAttr", (ins "firrtl::NameKindEnumAttr":$nameKind),
                                       [{}], /*defaultImplementation=*/[{
      this->getOperation()->setAttr("nameKind", nameKind);
    }]>,
    InterfaceMethod<"Return the name.",
    "mlir::StringAttr", "getNameAttr", (ins), [{}],
    /*defaultImplementation=*/[{
      return this->getOperation()->template
             getAttrOfType<mlir::StringAttr>("name");
    }]>,
    InterfaceMethod<"Return the name.",
    "llvm::StringRef", "getName", (ins), [{}],
    /*defaultImplementation=*/[{
      return getNameAttr();
    }]>
  ];
}

#endif // CIRCT_DIALECT_FIRRTL_FIRRTLOPINTERFACES_TD

<?xml version="1.0"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">

<xs:element name="Plugin">
  <xs:complexType>
    <xs:sequence>
      <xs:element name="Command" maxOccurs="unbounded">
        <xs:complexType>
          <xs:sequence>
            <!-- order matters -->
            <xs:element ref="Help" minOccurs="0" maxOccurs="unbounded"/>
            <xs:element ref="Input"/>
            <xs:element ref="Output"/>
          </xs:sequence>
	  <xs:attribute name="id" type="feProcedureId" use="required"/>
          <xs:attribute name="name" type="feName" use="required"/>
        </xs:complexType>
      </xs:element>
    </xs:sequence>
    <xs:attribute name="id" type="fePluginId" use="required"/>
  </xs:complexType>
</xs:element>

<xs:element name="Argument">
  <xs:complexType>
    <xs:choice minOccurs="0" maxOccurs="unbounded"> 
      <!-- order does not matter -->
      <xs:element ref="Help"/>
      <xs:element ref="Value"/>
    </xs:choice>
    <xs:attribute name="name" type="feName" use="required"/>
    <xs:attribute name="data" type="feName" use="optional"/>
    <xs:attribute name="optional" type="xs:boolean" use="optional"/>
  </xs:complexType>
</xs:element>

<xs:element name="Help" type="xs:string"/>

<xs:element name="Input">
  <xs:complexType>
    <xs:sequence> 
      <!-- order matters -->
      <xs:element ref="Argument" minOccurs="0" maxOccurs="unbounded"/>
      <xs:element ref="Option" minOccurs="0" maxOccurs="unbounded"/>
    </xs:sequence>
    <xs:attribute name="optionprefix" type="xs:string" use="optional"/>
  </xs:complexType>
</xs:element>

<xs:element name="Option">
  <xs:complexType>
    <xs:choice minOccurs="0" maxOccurs="unbounded"> 
      <!-- order does not matter -->
      <xs:element ref="Help"/>
      <xs:element ref="Set"/>
      <xs:element ref="Argument"/>
    </xs:choice>
    <xs:attribute name="name" type="feName" use="required"/>
    <xs:attribute name="optional" type="xs:boolean" use="optional"/>
    <xs:attribute name="group" type="feName" use="optional"/>
  </xs:complexType>
</xs:element>

<xs:element name="Output">
  <xs:complexType>
    <xs:sequence>
      <xs:element ref="Data" minOccurs="0" maxOccurs="unbounded"/>
    </xs:sequence>
  </xs:complexType>
</xs:element>

<xs:element name="Data">
  <xs:complexType>
    <xs:attribute name="name" type="feName" use="required"/>
    <xs:attribute name="type" type="feType" use="required"/>
    <xs:attribute name="default" type="xs:string" use="optional"/>
  </xs:complexType>
</xs:element>

<xs:element name="Set">
  <xs:complexType>
    <xs:attribute name="data" type="feName" use="required"/>
    <xs:attribute name="value" type="xs:string" use="required"/>
  </xs:complexType>
</xs:element>

<xs:element name="Value">
  <xs:complexType>
    <xs:sequence>
      <xs:element ref="Set" minOccurs="0" maxOccurs="unbounded"/>
    </xs:sequence>
    <xs:attribute name="string" type="xs:string" use="required"/>
  </xs:complexType>
</xs:element>

<!-- Types -->
<xs:simpleType name="feType">
  <xs:restriction base="xs:string">
    <xs:enumeration value="int8_t"/>
    <xs:enumeration value="uint8_t"/>
    <xs:enumeration value="int16_t"/>
    <xs:enumeration value="uint16_t"/>
    <xs:enumeration value="int32_t"/>
    <xs:enumeration value="int64_t"/>
    <xs:enumeration value="uint32_t"/>
    <xs:enumeration value="uint64_t"/>
    <xs:enumeration value="bool"/>
    <xs:enumeration value="string"/>
    <xs:enumeration value="wstring"/>
    <xs:enumeration value="bytearray"/>
    <xs:enumeration value="datetime64_t"/>
    <xs:enumeration value="ipv4addr"/>
    <xs:enumeration value="time32_t"/>
    <xs:enumeration value="time64_t"/>
  </xs:restriction>
</xs:simpleType>

<xs:simpleType name="fePluginId">
  <xs:restriction base="xs:short">
    <xs:minInclusive value="1"/>
  </xs:restriction>
</xs:simpleType>

<xs:simpleType name="feProcedureId">
  <xs:restriction base="xs:byte">
    <xs:minInclusive value="16"/>
  </xs:restriction>
</xs:simpleType>

<xs:simpleType name="feName">
  <xs:restriction base="xs:string">
    <xs:minLength value="1"/>
  </xs:restriction>
</xs:simpleType>

</xs:schema>
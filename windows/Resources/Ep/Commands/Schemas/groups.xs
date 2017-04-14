<?xml version="1.0"?>
<xs:schema targetNamespace="urn:ddb:expandingpulley"
           xmlns='urn:ddb:expandingpulley'           
           xmlns:xs="http://www.w3.org/2001/XMLSchema" >

 <xs:include schemaLocation="commonDefs.xs" />

 <xs:element name="Data">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="Instance"  />
    <xs:element ref="Command"/>
    <xs:choice minOccurs="0" maxOccurs="unbounded">
     <xs:element ref="Group" />
     <xs:element ref="Autoload" />
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="Group">
  <xs:complexType>
   <xs:sequence>
    <xs:element name="Attributes" form="qualified">
     <xs:complexType>
      <xs:sequence>
       <xs:element name="SeGroupEnabled" form="qualified" type="feEmptyElement" minOccurs="0" />
       <xs:element name="SeGroupEnabledByDefault" form="qualified" type="feEmptyElement" minOccurs="0" />
       <xs:element name="SeGroupLogonId" form="qualified" type="feEmptyElement" minOccurs="0" />
       <xs:element name="SeGroupMandatory" form="qualified" type="feEmptyElement" minOccurs="0" />
       <xs:element name="SeGroupOwner" form="qualified" type="feEmptyElement" minOccurs="0" />
       <xs:element name="SeGroupResource" form="qualified" type="feEmptyElement" minOccurs="0" />
       <xs:element name="SeGroupUseForDenyOnly" form="qualified" type="feEmptyElement" minOccurs="0" />
      </xs:sequence>
      <xs:attribute name="mask"               type="xs:string" use="required" />
     </xs:complexType>
    </xs:element>
   </xs:sequence>
   <xs:attribute name="comment"                  type="xs:string"             use="required" />
   <xs:attribute name="group"                    type="xs:string"             use="required" />
   <xs:attribute name="lptimestamp"              type="xs:dateTime"           use="required" />
   <xs:attribute name="group_id"                 type="xs:string"             use="required" />
  </xs:complexType>
 </xs:element>

</xs:schema>

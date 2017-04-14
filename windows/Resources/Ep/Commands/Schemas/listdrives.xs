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
    <xs:element ref="Autoload" minOccurs="0" maxOccurs="unbounded" />
    <xs:choice minOccurs="0" maxOccurs="unbounded">
     <xs:element ref="Drive" />
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="Drive">
  <xs:complexType>
   <xs:attribute name="cdrom"        type="xs:boolean" />
   <xs:attribute name="fixed"        type="xs:boolean" />
   <xs:attribute name="lptimestamp"  type="xs:dateTime" />
   <xs:attribute name="noroot"       type="xs:boolean" />
   <xs:attribute name="ramdisk"      type="xs:boolean" />
   <xs:attribute name="remote"       type="xs:boolean" />
   <xs:attribute name="removable"    type="xs:boolean" />
   <xs:attribute name="unknown"      type="xs:boolean" />
   <xs:attribute name="path"         type="xs:string" />

  </xs:complexType>
 </xs:element>
</xs:schema>

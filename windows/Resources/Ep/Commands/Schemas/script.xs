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
     <xs:element ref="Autoload" minOccurs="0" maxOccurs="unbounded" />
     <xs:element ref="Error" />
     <xs:element name="CtrlC" form="qualified" type="feEmptyElementWithTimestamp" />
     <xs:element name="Skip" form="qualified" type="feEmptyElementWithTimestamp" />
     <xs:element ref="SetEnv" />
     <xs:element name="Input" form="qualified" type="feStringElementWithTimestamp" />
     <xs:element name="Yes" form="qualified" type="feEmptyElement" />
     <xs:element name="Quit" form="qualified" type="feEmptyElement" />
     <xs:element name="No" form="qualified" type="feEmptyElement" />
     <xs:element name="Line" type="xs:string" form="qualified" />
     <xs:element name="Echo" type="feStringElementWithTimestamp" form="qualified"/>
     <xs:element ref="Pause"/>
     <xs:element ref="Resume"/>
     <xs:element ref="Storage"/>
     <xs:element ref="RunningCmd" />
     <xs:element ref="Info" />
     <xs:element ref="Alias" />
     <xs:element ref="Prompt" />
     <xs:element ref="Warning" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>
 
 <xs:element name="RunningCmd">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="xs:string">
     <xs:attribute name="lptimestamp" type="xs:dateTime" />
     <xs:attribute name="wait"      type="xs:nonNegativeInteger" />
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>  
 </xs:element>

 <xs:element name="Info">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="xs:string">
     <xs:attribute name="lptimestamp" type="xs:dateTime" />
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>  
 </xs:element>

 <xs:element name="Alias">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="xs:string">
     <xs:attribute name="lptimestamp" type="xs:dateTime" />
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>  
 </xs:element>

 <xs:element name="SetEnv">
  <xs:complexType>
   <xs:attribute name="name"  use="required" type="xs:string" />
   <xs:attribute name="value" use="required" type="xs:string" />
   <xs:attribute name="lptimestamp" type="xs:dateTime" />
  </xs:complexType>
 </xs:element>

 <xs:element name="Pause">
  <xs:complexType>
   <xs:simpleContent>
     <xs:extension base="xs:string">
      <xs:attribute name="script"  use="optional" type="xs:string" />
      <xs:attribute name="continue" use="optional" type="xs:string" />
      <xs:attribute name="lptimestamp" type="xs:dateTime" use="optional"/>
     </xs:extension>
    </xs:simpleContent>
  </xs:complexType>
 </xs:element>

 <xs:element name="Resume">
  <xs:complexType>
   <xs:attribute name="script"  use="optional" type="xs:string" />
   <xs:attribute name="lptimestamp" type="xs:dateTime" use="optional"/>
  </xs:complexType>
 </xs:element>

 <xs:element name="Prompt">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="xs:string">
     <xs:attribute name="type"  use="optional" type="xs:string" />
     <xs:attribute name="lptimestamp" type="xs:dateTime" use="optional"/>
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>  
 </xs:element>

 <xs:element name="Storage">
  <xs:complexType>
   <xs:attribute name="type"  use="required" type="xs:string" />
   <xs:attribute name="name"  use="required" type="xs:string" />
   <xs:attribute name="value"  use="required" type="xs:string" />
   <xs:attribute name="lptimestamp" type="xs:dateTime" use="optional"/>
  </xs:complexType>
 </xs:element>

 <xs:element name="Warning">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="xs:string">
     <xs:attribute name="lptimestamp" type="xs:dateTime" use="optional"/>
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>  
 </xs:element>


</xs:schema>


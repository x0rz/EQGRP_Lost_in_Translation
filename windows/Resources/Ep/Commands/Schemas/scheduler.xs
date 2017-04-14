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
     <xs:element ref="Error" />
     <xs:element ref="AtHeader" />
     <xs:element ref="AtJob" />
     <xs:element ref="NetJob" />
     <xs:element ref="NewJob" />
     <xs:element ref="Deleted" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="AtJob">
  <xs:complexType>
   <xs:sequence>
    <xs:element name="CommandText" form="qualified" type="xs:string" />
    <xs:element name="Time"        form="qualified" type="xs:string" />
    <xs:element ref="Weekday"/>
    <xs:element ref="Monthday"/>
    <xs:element ref="Flags"/>
   </xs:sequence>
   <xs:attribute name="id"        use="required" type="xs:nonNegativeInteger" />
   <xs:attribute name="lptimestamp" use="required" type="xs:dateTime" />
  </xs:complexType>
 </xs:element>

 <xs:element name="AtHeader" type="feEmptyElementWithTimestamp"/>

 <xs:element name="NetJob">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="NextRun"/>
    <xs:element name="JobName" form="qualified" type="xs:string" />
    <xs:element ref="Flags"/>
    <xs:element name="Application" form="qualified" type="xs:string" />
    <xs:element name="Parameters" form="qualified" type="xs:string" />
    <xs:element name="Account" form="qualified" type="xs:string" />
    <xs:element ref="Triggers"/>
   </xs:sequence>
   <xs:attribute name="exitcode"    use="required" type="xs:integer" />
   <xs:attribute name="lptimestamp" use="required" type="xs:dateTime" />
  </xs:complexType>
 </xs:element>

 <xs:element name="NewJob">
  <xs:complexType>
   <xs:attribute name="lptimestamp" use="required" type="xs:dateTime"/>
   <xs:attribute name="id"          use="required" type="xs:nonNegativeInteger"/>
  </xs:complexType>
 </xs:element>

 <xs:element name="Deleted" type="feEmptyElementWithTimestamp"/>

 <xs:element name="Triggers">
  <xs:complexType>
   <xs:sequence>
    <xs:element name="Trigger" form="qualified" type="xs:string" minOccurs="0" maxOccurs="unbounded"/>
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="Weekday">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="feEmptyElement">
     <xs:attribute name="mask" use="required" type="feHex"/>
     <xs:attribute name="monday" use="required" type="xs:boolean"/>
     <xs:attribute name="tuesday" use="required" type="xs:boolean"/>
     <xs:attribute name="wednesday" use="required" type="xs:boolean"/>
     <xs:attribute name="thursday" use="required" type="xs:boolean"/>
     <xs:attribute name="friday" use="required" type="xs:boolean"/>
     <xs:attribute name="saturday" use="required" type="xs:boolean"/>
     <xs:attribute name="sunday" use="required" type="xs:boolean"/>
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>

 <xs:element name="Monthday">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="feEmptyElement">
     <xs:attribute name="mask" use="required" type="feHex"/>
     <xs:attribute name="days" use="required" type="xs:string"/>
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>

 <xs:element name="NextRun">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="emptyDateTime">
     <xs:attribute name="locale" use="required" type="xs:string" />
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>

 <xs:element name="Flags">
   <xs:complexType>
      <xs:sequence>
       <xs:element name="JobNonInteractive"  form="qualified" minOccurs="0" type="feEmptyElement"/>
       <xs:element name="JobRunsToday"       form="qualified" minOccurs="0" type="feEmptyElement"/>
       <xs:element name="JobExecError"       form="qualified" minOccurs="0" type="feEmptyElement"/>
       <xs:element name="JobRunPeriodically" form="qualified" minOccurs="0" type="feEmptyElement"/>
       <xs:element name="JobAddCurrentDate"  form="qualified" minOccurs="0" type="feEmptyElement"/>
      </xs:sequence>
      <xs:attribute name="mask" use="required" type="feHex" />
   </xs:complexType>
 </xs:element>

 <xs:simpleType name="emptyDateTime">
  <xs:union>
   <xs:simpleType>
    <xs:restriction base="xs:dateTime"/>
   </xs:simpleType>
   <xs:simpleType>
    <xs:restriction base="xs:string">
     <xs:enumeration value="0000-00-00T00:00:00" />
    </xs:restriction>
   </xs:simpleType>
  </xs:union>
 </xs:simpleType>

</xs:schema>

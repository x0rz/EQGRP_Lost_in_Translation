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
     <xs:element ref="Filter" />
     <xs:element ref="Status" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="Filter">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="AdapterFilter"/>
    <xs:element ref="BpfFilter"/>
    <xs:element ref="BpfFilterInstructions"/>
   </xs:sequence>
   <xs:attribute name="lptimestamp" type="xs:dateTime" use='required'/>
  </xs:complexType>
 </xs:element>

 <xs:element name="AdapterFilter">
  <xs:complexType>
   <xs:choice minOccurs="0" maxOccurs="unbounded">
    <xs:element name="NdisPacketTypeDirected" form="qualified" type="feEmptyElement"/>
    <xs:element name="NdisPacketTypeMulticast" form="qualified" type="feEmptyElement"/>
    <xs:element name="NdisPacketTypeAllMulticast" form="qualified" type="feEmptyElement"/>
    <xs:element name="NdisPacketTypeBroadcast" form="qualified" type="feEmptyElement"/>
    <xs:element name="NdisPacketTypeSourceRouting" form="qualified" type="feEmptyElement"/>
    <xs:element name="NdisPacketTypePromiscuous" form="qualified" type="feEmptyElement"/>
    <xs:element name="NdisPacketTypeSmt" form="qualified" type="feEmptyElement"/>
    <xs:element name="NdisPacketTypeAllLocal" form="qualified" type="feEmptyElement"/>
    <xs:element name="NdisPacketTypeMacFrame" form="qualified" type="feEmptyElement"/>
    <xs:element name="NdisPacketTypeFunctional" form="qualified" type="feEmptyElement"/>
    <xs:element name="NdisPacketTypeAllFunctional" form="qualified" type="feEmptyElement"/>
    <xs:element name="NdisPacketTypeGroup" form="qualified" type="feEmptyElement"/>
   </xs:choice>
   <xs:attribute name="value" type="feHex" use='required'/>
  </xs:complexType>
 </xs:element>

 <xs:element name="BpfFilter">
  <xs:complexType>
  <xs:simpleContent>
    <xs:extension base="xs:string">
     <xs:attribute name="length" type="xs:nonNegativeInteger" use="required"/>
    </xs:extension>
  </xs:simpleContent>
  </xs:complexType>
 </xs:element>

 <xs:element name="BpfFilterInstructions">
  <xs:complexType>
   <xs:sequence>
     <xs:element name="Instruction" form="qualified" type="xs:string" minOccurs="0" maxOccurs="unbounded"/>
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="Status">
  <xs:complexType>
   <xs:choice minOccurs="1">
	<xs:element ref="Version"/>
   </xs:choice>
   <xs:attribute name="filterActive" type="xs:boolean" use='required'/>
   <xs:attribute name="threadRunning" type="xs:boolean" use='required'/>
   <xs:attribute name="maxCaptureSize" type="xs:nonNegativeInteger" use='required'/>
   <xs:attribute name="maxPacketSize" type="xs:nonNegativeInteger" use='required'/>
   <xs:attribute name="captureFile" type="xs:string" use='required'/>
   <xs:attribute name="lptimestamp" type="xs:dateTime" use='required'/>
  </xs:complexType>
 </xs:element>

<xs:element name="Version">
  <xs:complexType>
   <xs:attribute name="major" type="xs:nonNegativeInteger" use='required'/>
   <xs:attribute name="minor" type="xs:nonNegativeInteger" use='required'/>
   <xs:attribute name="revision" type="xs:nonNegativeInteger" use='required'/>
  </xs:complexType>
 </xs:element>
 
</xs:schema>

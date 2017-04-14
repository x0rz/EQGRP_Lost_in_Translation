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
     <xs:element ref="Device" />
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice minOccurs="0">
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

  <xs:element name='Device'>
    <xs:complexType>
	<xs:sequence>
	  <xs:element name='FriendlyName'   form='qualified' type='xs:string'/>
	  <xs:element name='DeviceDesc'     form='qualified' type='xs:string'/>
	  <xs:element name='HardwareID'     form='qualified' type='xs:string'/>
	  <xs:element name='ServicePath'    form='qualified' type='xs:string'/>
	  <xs:element name='Driver'         form='qualified' type='xs:string'/>
	  <xs:element name='LocationInfo'   form='qualified' type='xs:string'/>
	  <xs:element name='Mfg'            form='qualified' type='xs:string'/>
	  <xs:element name='PhysDevObjName' form='qualified' type='xs:string'/>
	</xs:sequence>
	<xs:attribute name='index' type='xs:nonNegativeInteger' use='required'/>
	<xs:attribute name='lptimestamp' type='xs:dateTime' use='required'/>
    </xs:complexType>
  </xs:element>


</xs:schema>

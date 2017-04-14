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
     <xs:element ref="Drivers" />
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice minOccurs="0">
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

  <xs:element name='Drivers'>
    <xs:complexType>
	<xs:sequence>
	  <xs:element name='Driver'   form='qualified' minOccurs="0" maxOccurs="unbounded">
	    <xs:complexType>
	     <xs:simpleContent>
	      <xs:extension base="xs:string">
	       <xs:attribute name="base"      type="feHex" use='required'/>
	       <xs:attribute name="size"      type="xs:nonNegativeInteger" use='required'/>
	       <xs:attribute name="flags"     type="feHex" use='required'/>
	       <xs:attribute name="index"      type="xs:nonNegativeInteger" use='required'/>
	       <xs:attribute name="loadCount"      type="xs:nonNegativeInteger" use='required'/>
	      </xs:extension>
	     </xs:simpleContent>
	    </xs:complexType>
            
          </xs:element>
	</xs:sequence>
	<xs:attribute name='lptimestamp' type='xs:dateTime' use='required'/>
    </xs:complexType>
  </xs:element>


</xs:schema>

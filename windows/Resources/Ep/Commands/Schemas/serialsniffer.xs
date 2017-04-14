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
    <xs:choice minOccurs="1" maxOccurs="unbounded">
     <xs:sequence>
      <xs:element ref="Version" />
      <xs:element ref="Device" minOccurs="0" maxOccurs="unbounded" />
     </xs:sequence>
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

  <xs:element name='Version'>
    <xs:complexType>
        <xs:simpleContent>
            <xs:extension base='xs:string'>
                <xs:attribute name='lptimestamp' type='xs:dateTime' use='required'/>
                <xs:attribute name='major' type='xs:nonNegativeInteger' use='required'/>
                <xs:attribute name='minor' type='xs:nonNegativeInteger' use='required'/>
                <xs:attribute name='revision' type='xs:nonNegativeInteger' use='required'/>
            </xs:extension>
        </xs:simpleContent>
    </xs:complexType>
  </xs:element>
  
  <xs:element name='Device'>
    <xs:complexType>
        <xs:simpleContent>
            <xs:extension base='xs:string'>
               <xs:attribute name='lptimestamp' type='xs:dateTime' use='required'/>
               <xs:attribute name='id' type='xs:nonNegativeInteger' use='required'/>
               <xs:attribute name='isListening' type='xs:boolean' use='required'/>
            </xs:extension>
        </xs:simpleContent>
    </xs:complexType>
  </xs:element>
</xs:schema>

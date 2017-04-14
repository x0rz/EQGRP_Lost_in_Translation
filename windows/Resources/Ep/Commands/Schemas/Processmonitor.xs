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
     <xs:element ref="Processes" />
     <xs:element ref="Process" />
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice minOccurs="0">
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>
  
  <xs:element name='Processes'>
    <xs:complexType>
	<xs:sequence>
	  <xs:element ref='Process' minOccurs='0' maxOccurs='unbounded'/>
	</xs:sequence>
	<xs:attribute name='lptimestamp' type='xs:dateTime' use='required'/>
    </xs:complexType>
  </xs:element>

  <xs:element name='Process'>
    <xs:complexType>
      <xs:simpleContent>
       <xs:extension base='xs:string'>
        <xs:attribute name='id'       type='xs:string'             use='required' />
        <xs:attribute name='parent'   type='xs:string'             use='required' />
        <xs:attribute name='comment'  type='xs:string'             use='required' />
        <xs:attribute name='kernTime' type='xs:dateTime'           use='optional' />
        <xs:attribute name='procTime' type='xs:dateTime'           use='optional' />
        <xs:attribute name='userTime' type='xs:dateTime'           use='optional' />
        <xs:attribute name='threads'  type='xs:nonNegativeInteger' use='optional' />
        <xs:attribute name='usage'    type='xs:nonNegativeInteger' use='optional' />
        <xs:attribute name='started'  type='xs:boolean'            use='optional' />
        <xs:attribute name='ignore'   type='xs:nonNegativeInteger' use='optional' />
	<xs:attribute name='lptimestamp' type='xs:dateTime' use='optional'/>
       </xs:extension>
      </xs:simpleContent>
    </xs:complexType>
  </xs:element>

</xs:schema>

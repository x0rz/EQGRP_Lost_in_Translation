<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="LotusNotesParser"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="LotusNotesParser">
    <xsl:apply-templates select="Email"/>
   	<xsl:element name="Storage">
           <xsl:attribute name="type">int</xsl:attribute>
           <xsl:attribute name="name">msgsProcessed</xsl:attribute>
           <xsl:attribute name="value"><xsl:value-of select="@msgsProcessed"/></xsl:attribute>
   	</xsl:element>
  </xsl:template>

    <xsl:template match="Email">
	<xsl:apply-templates select="MsgID"/>
	<xsl:apply-templates select="To"/>
	<xsl:apply-templates select="From"/>
	<xsl:apply-templates select="CC"/>
	<xsl:apply-templates select="Bcc"/>
	<xsl:apply-templates select="Subject"/>
	<xsl:apply-templates select="ComposedDate"/>
	<xsl:apply-templates select="PostedDate"/>
	<xsl:apply-templates select="DeliveredDate"/>
	<xsl:apply-templates select="Body"/>
   	<xsl:element name="Storage">
           <xsl:attribute name="type">bool</xsl:attribute>
           <xsl:attribute name="name">bodyReq</xsl:attribute>
           <xsl:attribute name="value"><xsl:value-of select="@bodyReq"/></xsl:attribute>
   	</xsl:element>
    	<xsl:element name="Storage">
           <xsl:attribute name="type">int</xsl:attribute>
           <xsl:attribute name="name">numAtt</xsl:attribute>
           <xsl:attribute name="value"><xsl:value-of select="@numAtt"/></xsl:attribute>
   	</xsl:element>
        <xsl:apply-templates select="Attachment"/>	
    </xsl:template>

    <xsl:template match="MsgID">
    	<xsl:element name="Storage">
      	   <xsl:attribute name="type">int</xsl:attribute>
      	   <xsl:attribute name="name">msgID</xsl:attribute>
      	   <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template match="To">
       <xsl:element name="Storage">
          <xsl:attribute name="type">string</xsl:attribute>
          <xsl:attribute name="name">to</xsl:attribute>
         <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
       </xsl:element>
    </xsl:template>

    <xsl:template match="From">
       <xsl:element name="Storage">
          <xsl:attribute name="type">string</xsl:attribute>
          <xsl:attribute name="name">from</xsl:attribute>
         <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
       </xsl:element>
    </xsl:template>

    <xsl:template match="CC">
       <xsl:element name="Storage">
          <xsl:attribute name="type">string</xsl:attribute>
          <xsl:attribute name="name">cc</xsl:attribute>
         <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
       </xsl:element>
    </xsl:template>

    <xsl:template match="Bcc">
       <xsl:element name="Storage">
          <xsl:attribute name="type">string</xsl:attribute>
          <xsl:attribute name="name">bcc</xsl:attribute>
         <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
       </xsl:element>
    </xsl:template>

    <xsl:template match="Subject">
       <xsl:element name="Storage">
          <xsl:attribute name="type">string</xsl:attribute>
          <xsl:attribute name="name">subject</xsl:attribute>
         <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
       </xsl:element>
    </xsl:template>

    <xsl:template match="ComposedDate">
       <xsl:element name="Storage">
          <xsl:attribute name="type">string</xsl:attribute>
          <xsl:attribute name="name">composedDate</xsl:attribute>
         <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
       </xsl:element>
    </xsl:template>

    <xsl:template match="PostedDate">
       <xsl:element name="Storage">
          <xsl:attribute name="type">string</xsl:attribute>
          <xsl:attribute name="name">postedDate</xsl:attribute>
         <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
       </xsl:element>
    </xsl:template>

    <xsl:template match="DeliveredDate">
       <xsl:element name="Storage">
          <xsl:attribute name="type">string</xsl:attribute>
          <xsl:attribute name="name">deliveredDate</xsl:attribute>
         <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
       </xsl:element>
    </xsl:template>

    <xsl:template match="Body">
       <xsl:element name="Storage">
          <xsl:attribute name="type">string</xsl:attribute>
          <xsl:attribute name="name">body</xsl:attribute>
         <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
       </xsl:element>
    </xsl:template>

    <xsl:template match="Attachment">
      <xsl:element name="Storage">
         <xsl:attribute name="type">int</xsl:attribute>
         <xsl:attribute name="name">attSize</xsl:attribute>
         <xsl:attribute name="value"><xsl:value-of select="@attSize"/></xsl:attribute>
      </xsl:element>

      <xsl:element name="Storage">
         <xsl:attribute name="type">string</xsl:attribute>
         <xsl:attribute name="name">attName</xsl:attribute>
         <xsl:attribute name="value"><xsl:value-of select="@attName"/></xsl:attribute>
      </xsl:element>
   </xsl:template>

</xsl:transform>









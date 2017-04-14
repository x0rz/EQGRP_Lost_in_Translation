<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="StandardTransforms.xsl"/>

	<xsl:output method="xml" omit-xml-declaration="no"/>

	<xsl:template match="/"> 
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="LSA_Secret"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="LSA_Secret">
		<xsl:element name="Storage">
			<xsl:attribute name="type">string</xsl:attribute> 
			<xsl:attribute name="name">Secret</xsl:attribute> 
			<xsl:attribute name="value">
			<xsl:value-of select="Secret" /> 
			</xsl:attribute>
		</xsl:element>
		
	    <xsl:element name="Storage">
	   	  <xsl:attribute name="type">string</xsl:attribute> 
		  <xsl:attribute name="name">LSA_Data</xsl:attribute> 
 		  <xsl:choose>
		    <xsl:when test="LSA_Data">
			  <xsl:attribute name="value">
			     <xsl:value-of select="LSA_Data" /> 
			  </xsl:attribute>
		    </xsl:when>
		    <xsl:otherwise>
   		      <xsl:attribute name="value"></xsl:attribute> 
		    </xsl:otherwise>
 		  </xsl:choose>
		</xsl:element>
	</xsl:template>
</xsl:transform>




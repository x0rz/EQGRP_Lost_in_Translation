<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="PackageList"/>
			<xsl:call-template name="TaskingInfo">
				<xsl:with-param name="info" select="TaskingInfo"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="PackageList">
		<xsl:apply-templates select="Package" />
	</xsl:template>
	
	<xsl:template match="Package">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Package</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Name</xsl:attribute>
				<xsl:value-of select="@name" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Description</xsl:attribute>
				<xsl:value-of select="@desc" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Version</xsl:attribute>
				<xsl:value-of select="@version" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Revision</xsl:attribute>
				<xsl:value-of select="@revision" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Size</xsl:attribute>
				<xsl:value-of select="@size" />
			</xsl:element>
			<xsl:if test="InstallDate/@type != 'invalid'">
				<xsl:element name="StringValue">
					<xsl:attribute name="name">InstallDate</xsl:attribute>
					<xsl:value-of select="substring-before(InstallDate, 'T')"/>
				</xsl:element>
       				
       			<xsl:element name="StringValue">
					<xsl:attribute name="name">InstallTime</xsl:attribute>
					<xsl:value-of select="substring-before(substring-after(InstallDate, 'T'), '.')"/>
				</xsl:element>
      		</xsl:if>
			
		</xsl:element>
	</xsl:template>

</xsl:transform>
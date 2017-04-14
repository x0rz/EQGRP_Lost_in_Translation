<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates/>
			<xsl:call-template name="TaskingInfo">
				<xsl:with-param name="info" select="TaskingInfo"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="ImplantInfo">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ImplantInfo</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Version</xsl:attribute>
				<xsl:value-of select="Version" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Id</xsl:attribute>
				<xsl:value-of select="Id" />
			</xsl:element>
			
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="AttemptConnection">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">AttemptConnection</xsl:attribute>
			<xsl:call-template name="Endpoint">
				<xsl:with-param name="Address" select="Target"/>
				<xsl:with-param name="Name" select="'Destination'"/>
			</xsl:call-template>
			<xsl:call-template name="Endpoint">
				<xsl:with-param name="Address" select="Local"/>
				<xsl:with-param name="Name" select="'Source'"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="Endpoint">
		<xsl:param name="Address"/>
		<xsl:param name="Name"/>
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name"><xsl:value-of select="$Name"/></xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">IP</xsl:attribute>
				<xsl:value-of select="$Address/Address"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Port</xsl:attribute>
				<xsl:value-of select="$Address/Port"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="RemoteAddress">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">RemoteAddress</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">id</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:transform> 
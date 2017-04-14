<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes"/>
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="Devices/Device"/>
			<xsl:call-template name="TaskingInfo">
				<xsl:with-param name="info" select="TaskingInfo"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Device">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">DeviceItem</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">friendlyname</xsl:attribute>
				<xsl:value-of select="FriendlyName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">devicedesc</xsl:attribute>
				<xsl:value-of select="DeviceDesc"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">HardwareId</xsl:attribute>
				<xsl:value-of select="HardwareId"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">ServicePath</xsl:attribute>
				<xsl:value-of select="ServicePath"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Driver</xsl:attribute>
				<xsl:value-of select="Driver"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">LocationInfo</xsl:attribute>
				<xsl:value-of select="LocationInfo"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Mfg</xsl:attribute>
				<xsl:value-of select="Mfg"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">PhysDevObjName</xsl:attribute>
				<xsl:value-of select="PhysDevObjName"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:transform>
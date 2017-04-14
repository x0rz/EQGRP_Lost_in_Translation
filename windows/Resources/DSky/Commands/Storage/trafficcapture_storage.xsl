<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/"> 
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="Filter"/>
			<xsl:apply-templates select="Status"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Filter">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Filter</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">AdapterFilter</xsl:attribute>
				<xsl:value-of select="AdapterFilter/@value"/>
			</xsl:element>

			<xsl:element name="StringValue">
				<xsl:attribute name="name">BpfFilter</xsl:attribute>
				<xsl:value-of select="BpfFilter"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Status">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Status</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">VersionMajor</xsl:attribute>
				<xsl:value-of select="Version/@major"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">VersionMinor</xsl:attribute>
				<xsl:value-of select="Version/@minor"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">VersionRevision</xsl:attribute>
				<xsl:value-of select="Version/@revision"/>
			</xsl:element>

			<xsl:element name="BoolValue">
				<xsl:attribute name="name">FilterActive</xsl:attribute>
				<xsl:value-of select="@filterActive"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">ThreadRunning</xsl:attribute>
				<xsl:value-of select="@threadRunning"/>
			</xsl:element>

			<xsl:element name="IntValue">
				<xsl:attribute name="name">MaxFileSize</xsl:attribute>
				<xsl:value-of select="@maxCaptureSize"/>
			</xsl:element>

			<xsl:element name="IntValue">
				<xsl:attribute name="name">CaptureFileSize</xsl:attribute>
				<xsl:value-of select="@captureFileSize"/>
			</xsl:element>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">MaxPacketSize</xsl:attribute>
				<xsl:value-of select="@maxPacketSize"/>
			</xsl:element>

			<xsl:element name="StringValue">
				<xsl:attribute name="name">CaptureFile</xsl:attribute>
				<xsl:value-of select="@captureFile"/>
			</xsl:element>

			<xsl:element name="StringValue">
				<xsl:attribute name="name">EncryptionKey</xsl:attribute>
				<xsl:value-of select="EncryptionKey"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:transform>
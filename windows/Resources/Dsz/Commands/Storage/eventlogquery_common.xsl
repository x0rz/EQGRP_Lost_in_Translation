<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="Records">
		<xsl:apply-templates select="Record" />
	</xsl:template>
	<xsl:template match="Record">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Record</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">number</xsl:attribute>
				<xsl:value-of select="@number" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">eventType</xsl:attribute>
				<xsl:value-of select="@eventType" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">id</xsl:attribute>
				<xsl:value-of select="@code" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">ProcessId</xsl:attribute>
				<xsl:value-of select="@processId" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">ThreadId</xsl:attribute>
				<xsl:value-of select="@threadId" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">dateWritten</xsl:attribute>
				<xsl:value-of select="substring-before(TimeWritten, 'T')" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">timeWritten</xsl:attribute>
				<xsl:value-of select="substring-before(substring-after(TimeWritten, 'T'), '.')" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">computer</xsl:attribute>
				<xsl:value-of select="@computer" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">user</xsl:attribute>
				<xsl:value-of select="@sid" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">source</xsl:attribute>
				<xsl:value-of select="@source" />
			</xsl:element>		
			<xsl:apply-templates select="String" />
			<xsl:apply-templates select="Data" />		
		</xsl:element>
	</xsl:template>

	<xsl:template match="String">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">String</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">value</xsl:attribute>
				<xsl:value-of select="." />
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Data">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Data</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">value</xsl:attribute>
				<xsl:value-of select="." />
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:transform>
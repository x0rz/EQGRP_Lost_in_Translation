<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:output method="xml" omit-xml-declaration="yes"/>

	<xsl:template match="/"> 
		<xsl:element name="StorageObjects">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="RpcId">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Rpc</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Id</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="RpcResult">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Result</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Id</xsl:attribute>
				<xsl:value-of select="@rpcId"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Address</xsl:attribute>
				<xsl:value-of select="@address"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Status</xsl:attribute>
				<xsl:value-of select="@result"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">StatusString</xsl:attribute>
				<xsl:value-of select="@resultStr"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">GroupTag</xsl:attribute>
				<xsl:value-of select="@groupTag"/>
			</xsl:element>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Output</xsl:attribute>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">Length</xsl:attribute>
					<xsl:value-of select="OutputData/@length"/>
				</xsl:element>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Data</xsl:attribute>
					<xsl:value-of select="OutputData"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>


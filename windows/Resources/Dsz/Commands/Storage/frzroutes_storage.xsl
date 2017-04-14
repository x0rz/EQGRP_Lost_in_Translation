<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:output method="xml" omit-xml-declaration="yes"/>

	<xsl:template match="/"> 
		<xsl:element name="StorageObjects">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="TaskingInfo">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">TaskingInfo</xsl:attribute>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">TaskType</xsl:attribute>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Value</xsl:attribute>
					<xsl:value-of select="TaskType"/>
				</xsl:element>
			</xsl:element>
			<xsl:if test="Precedence">
				<xsl:element name="IntValue">
					<xsl:attribute name="name">Precedence</xsl:attribute>
					<xsl:value-of select="Precedence"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="Address">
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Address</xsl:attribute>
					<xsl:value-of select="Address"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="Mask">
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Mask</xsl:attribute>
					<xsl:value-of select="Mask"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="CidrBits">
				<xsl:element name="IntValue">
					<xsl:attribute name="name">CidrBits</xsl:attribute>
					<xsl:value-of select="CidrBits"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="LinkId">
				<xsl:element name="IntValue">
					<xsl:attribute name="name">LinkId</xsl:attribute>
					<xsl:value-of select="LinkId"/>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="FrzRoutes">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Routes</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NumRoutes</xsl:attribute>
				<xsl:value-of select="@numRoutes"/>
			</xsl:element>
			<xsl:apply-templates select="Route"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Route">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Route</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">LinkId</xsl:attribute>
				<xsl:value-of select="@linkId"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Precedence</xsl:attribute>
				<xsl:value-of select="@precedence"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Address</xsl:attribute>
				<xsl:value-of select="@address"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Mask</xsl:attribute>
				<xsl:value-of select="@mask"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">CidrBits</xsl:attribute>
				<xsl:value-of select="@cidrBits"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>


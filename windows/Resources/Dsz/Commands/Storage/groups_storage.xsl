<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="Groups"/>
			<xsl:call-template name="TaskingInfo">
				<xsl:with-param name="info" select="TaskingInfo"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Groups">
		<xsl:apply-templates select="Group"/>
	</xsl:template>
	
	<xsl:template match="Group">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Group</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">groupId</xsl:attribute>
				<xsl:value-of select="@groupId"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">group</xsl:attribute>
				<xsl:value-of select="@group"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">comment</xsl:attribute>
				<xsl:value-of select="@comment"/>
			</xsl:element>
			
			<xsl:apply-templates select="Attributes"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Attributes">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Attributes</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">mask</xsl:attribute>
				<xsl:value-of select="@mask"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">groupMandatory</xsl:attribute>
				<xsl:choose>
					<xsl:when test="SeGroupMandatory">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">groupEnabled</xsl:attribute>
				<xsl:choose>
					<xsl:when test="SeGroupEnabled">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">groupEnabledByDefault</xsl:attribute>
				<xsl:choose>
					<xsl:when test="SeGroupEnabledByDefault">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">groupLogonId</xsl:attribute>
				<xsl:choose>
					<xsl:when test="SeGroupLogonId">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">groupOwner</xsl:attribute>
				<xsl:choose>
					<xsl:when test="SeGroupOwner">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">groupResource</xsl:attribute>
				<xsl:choose>
					<xsl:when test="SeGroupResource">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">groupUseForDenyOnly</xsl:attribute>
				<xsl:choose>
					<xsl:when test="SeGroupUseForDenyOnly">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:transform>
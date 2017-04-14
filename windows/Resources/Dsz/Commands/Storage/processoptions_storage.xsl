<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="ExecuteOptions"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="ExecuteOptions">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Options</xsl:attribute>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Value</xsl:attribute>
				<xsl:value-of select="@value"/>
			</xsl:element>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">ProcessId</xsl:attribute>
				<xsl:value-of select="@processId"/>
			</xsl:element>
			
			<xsl:call-template name="Attributes">
				<xsl:with-param name="attr" select="ExecutionDisabled" />
				<xsl:with-param name="var" select="'ExecutionDisabled'" />
			</xsl:call-template>
			
			<xsl:call-template name="Attributes">
				<xsl:with-param name="attr" select="ExecutionEnabled" />
				<xsl:with-param name="var" select="'ExecutionEnabled'" />
			</xsl:call-template>
			
			<xsl:call-template name="Attributes">
				<xsl:with-param name="attr" select="DisableThunkEmulation" />
				<xsl:with-param name="var" select="'DisableThunkEmulation'" />
			</xsl:call-template>
			
			<xsl:call-template name="Attributes">
				<xsl:with-param name="attr" select="Permanent" />
				<xsl:with-param name="var" select="'Permanent'" />
			</xsl:call-template>
			
			<xsl:call-template name="Attributes">
				<xsl:with-param name="attr" select="ExecuteDispatchEnabled" />
				<xsl:with-param name="var" select="'ExecuteDispatchEnabled'" />
			</xsl:call-template>
			
			<xsl:call-template name="Attributes">
				<xsl:with-param name="attr" select="ImageDispatchEnabled" />
				<xsl:with-param name="var" select="'ImageDispatchEnabled'" />
			</xsl:call-template>
			
			<xsl:call-template name="Attributes">
				<xsl:with-param name="attr" select="DisableExceptionChainValidation" />
				<xsl:with-param name="var" select="'DisableExceptionChainValidation'" />
			</xsl:call-template>
			
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="Attributes">
		<xsl:param name="attr" />
		<xsl:param name="var" />
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">
				<xsl:value-of select="$var" />
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="$attr">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>
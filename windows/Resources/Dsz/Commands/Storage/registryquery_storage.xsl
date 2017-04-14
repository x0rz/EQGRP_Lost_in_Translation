<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="Keys/Key"/>
			<xsl:call-template name="TaskingInfo">
				<xsl:with-param name="info" select="TaskingInfo"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Key">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Key</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">hive</xsl:attribute>
				<xsl:value-of select="@hive"/>
			</xsl:element>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">name</xsl:attribute>
				<xsl:value-of select="@name"/>
			</xsl:element>

			<xsl:element name="StringValue">
				<xsl:attribute name="name">class</xsl:attribute>
				<xsl:value-of select="@class"/>
			</xsl:element>
			
			<!-- This is here because we need to duplicate the value because python doesn't like class as a value -->
			<xsl:element name="StringValue">
				<xsl:attribute name="name">KeyClass</xsl:attribute>
				<xsl:value-of select="@class"/>
			</xsl:element>

			<xsl:element name="StringValue">
				<xsl:attribute name="name">updateDate</xsl:attribute>
				<xsl:value-of select="substring-before(LastUpdate, 'T')"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">updateTime</xsl:attribute>
				<xsl:value-of select="substring-before(substring-after(LastUpdate, 'T'), '.')"/>
			</xsl:element>
		
			<xsl:apply-templates select="Subkey"/>
			<xsl:apply-templates select="Value"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Subkey">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Subkey</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">name</xsl:attribute>
				<xsl:value-of select="@name"/>
			</xsl:element>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">updateDate</xsl:attribute>
				<xsl:value-of select="substring-before(LastUpdate, 'T')"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">updateTime</xsl:attribute>
				<xsl:value-of select="substring-before(substring-after(LastUpdate, 'T'), '.')"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Value">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Value</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">name</xsl:attribute>
				<xsl:value-of select="@name"/>
			</xsl:element>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">type</xsl:attribute>
				<xsl:value-of select="@type"/>
			</xsl:element>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">typeValue</xsl:attribute>
				<xsl:value-of select="@typeValue"/>
			</xsl:element>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">value</xsl:attribute>
				<xsl:choose>
					<xsl:when test="Translated">
						<xsl:value-of select="Translated"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="Raw"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:element>
	</xsl:template>
  
</xsl:transform>
<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="xml" omit-xml-declaration="yes" />

	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="DatabaseOpen"/>
			<xsl:apply-templates select="DatabaseExec"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="DatabaseExec">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ResultItem</xsl:attribute>
			
			<xsl:for-each select="Column">
				<xsl:element name="StringValue">
					<xsl:attribute name="name">column</xsl:attribute>
					<xsl:value-of select="."/>
				</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="Row">
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">Row</xsl:attribute>
					
					<xsl:call-template name="PrintRow">
						<xsl:with-param name="columns" select="../Column"/>
					</xsl:call-template>
						
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="PrintRow">
		<xsl:param name="columns"/>
		<xsl:param name="index" select="1"/>
		
		<xsl:if test="count($columns) &gt;= $index">
			<xsl:element name="StringValue">
				<xsl:attribute name="name"><xsl:value-of select="$columns[$index]"/></xsl:attribute>
				<xsl:value-of select="Cell[$index]"/>
			</xsl:element>
			
			<xsl:call-template name="PrintRow">
				<xsl:with-param name="index" select="$index + 1"/>
				<xsl:with-param name="columns" select="$columns"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="DatabaseOpen">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ResultItem</xsl:attribute>
		
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Filename</xsl:attribute>
				<xsl:value-of select="Filename"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">handle</xsl:attribute>
				<xsl:value-of select="ConnectionId"/>
			</xsl:element>
		
			<xsl:apply-templates select="Row"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Row">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Row</xsl:attribute>
			
			<xsl:for-each select="Cell">
			</xsl:for-each>
		</xsl:element>
	</xsl:template>
</xsl:transform>

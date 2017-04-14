<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="Drivers"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Drivers">
		<xsl:apply-templates select="Driver"/>
	</xsl:template>
	
	<xsl:template match="Driver">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">DriverItem</xsl:attribute>
					
			<xsl:element name="IntValue">
				<xsl:attribute name="name">base</xsl:attribute>
				<xsl:value-of select="@base"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">flags</xsl:attribute>
				<xsl:value-of select="@flags"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">loadCount</xsl:attribute>
				<xsl:value-of select="@loadCount"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">size</xsl:attribute>
				<xsl:value-of select="@size"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Signed</xsl:attribute>
				<xsl:choose>
					<xsl:when test="Signed">
						<xsl:element name="Good">
							<xsl:text>YES</xsl:text>
						</xsl:element>
					</xsl:when>
					<xsl:when test="Unsigned">
						<xsl:element name="Error">
							<xsl:text>NO</xsl:text>
						</xsl:element>
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="Warning">
							<xsl:text>UNKNOWN</xsl:text>
						</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<!-- add buildDate once someone is returning it -->
			<xsl:element name="StringValue">
				<xsl:attribute name="name">name</xsl:attribute>
				<xsl:value-of select="Name"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">author</xsl:attribute>
				<xsl:value-of select="Author"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">license</xsl:attribute>
				<xsl:value-of select="License"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Version</xsl:attribute>
				<xsl:value-of select="Version"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Description</xsl:attribute>
				<xsl:value-of select="Description"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Comments</xsl:attribute>
				<xsl:value-of select="Comments"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">InternalName</xsl:attribute>
				<xsl:value-of select="InternalName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">OriginalName</xsl:attribute>
				<xsl:value-of select="OriginalName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">ProductName</xsl:attribute>
				<xsl:value-of select="ProductName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Trademark</xsl:attribute>
				<xsl:value-of select="Trademark"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">filePath</xsl:attribute>
				<xsl:value-of select="FilePath"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">usedByMods</xsl:attribute>
				<xsl:value-of select="UsedByModules"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">dependencies</xsl:attribute>
				<xsl:value-of select="Dependencies"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">alias</xsl:attribute>
				<xsl:value-of select="Alias"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">loadParams</xsl:attribute>
				<xsl:value-of select="LoadParameters"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>

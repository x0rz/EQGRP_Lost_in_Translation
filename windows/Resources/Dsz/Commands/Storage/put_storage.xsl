<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:output method="xml" omit-xml-declaration="yes"/>

	<xsl:template match="/"> 
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="PutFile"/>
			<xsl:apply-templates select="Results"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="PutFile"> 
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">LocalFile</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Name</xsl:attribute>
				<xsl:value-of select="@name"/>
			</xsl:element>
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Size</xsl:attribute>
				<xsl:value-of select="@size"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Results">
		<xsl:choose>
			<xsl:when test="File">
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">File</xsl:attribute>

					<xsl:element name="StringValue">
						<xsl:attribute name="name">Name</xsl:attribute>
						<xsl:value-of select="File/."/>
					</xsl:element>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">File</xsl:attribute>

					<xsl:element name="IntValue">
						<xsl:attribute name="name">BytesWritten</xsl:attribute>
						<xsl:value-of select="@bytesWritten"/>
					</xsl:element>
					<xsl:element name="IntValue">
						<xsl:attribute name="name">BytesRemaining</xsl:attribute>
						<xsl:value-of select="@bytesLeft"/>
					</xsl:element>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:transform>
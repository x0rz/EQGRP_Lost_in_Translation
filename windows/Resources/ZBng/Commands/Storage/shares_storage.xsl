<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="QueryResponse">
		<xsl:apply-templates select="Resource"/>
	</xsl:template>
	<xsl:template match="Shares">
		<xsl:apply-templates select="Share"/>
	</xsl:template>
	
	<xsl:template match="MapResponse">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">MappedResource</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">RemotePath</xsl:attribute>
				<xsl:value-of select="ResourcePath"/>
			</xsl:element>
			
			<xsl:if test="ResourceName">
				<xsl:element name="StringValue">
					<xsl:attribute name="name">LocalPath</xsl:attribute>
					<xsl:value-of select="ResourceName"/>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Share">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Share</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">localname</xsl:attribute>
				<xsl:value-of select="LocalName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">remotename</xsl:attribute>
				<xsl:value-of select="RemoteName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">username</xsl:attribute>
				<xsl:value-of select="UserName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">domainname</xsl:attribute>
				<xsl:value-of select="DomainName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">password</xsl:attribute>
				<xsl:value-of select="Password"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">status</xsl:attribute>
				<xsl:value-of select="Status"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">type</xsl:attribute>
				<xsl:value-of select="Type"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">referenceCount</xsl:attribute>
				<xsl:value-of select="@referenceCount"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">useCount</xsl:attribute>
				<xsl:value-of select="@useCount"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Resource">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Resource</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">name</xsl:attribute>
				<xsl:value-of select="Name"/>
			</xsl:element>
			
			<xsl:if test="Path">
				<xsl:element name="StringValue">
					<xsl:attribute name="name">path</xsl:attribute>
					<xsl:value-of select="Path"/>
				</xsl:element>
			</xsl:if>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">type</xsl:attribute>
				<xsl:value-of select="Type"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">admin</xsl:attribute>
				<xsl:value-of select="Type/@admin"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">caption</xsl:attribute>
				<xsl:value-of select="Caption"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">description</xsl:attribute>
				<xsl:value-of select="Description"/>
			</xsl:element>

		</xsl:element>
	</xsl:template>
</xsl:transform>
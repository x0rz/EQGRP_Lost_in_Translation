<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="Drives" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Drives">
		<xsl:apply-templates select="Drive" />
	</xsl:template>
	
	<xsl:template match="Drive">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">DriveItem</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">timestamp</xsl:attribute>
				<xsl:value-of select="@lptimestamp"/>
			</xsl:element>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">serialNumber</xsl:attribute>
				<xsl:value-of select="SerialNumber" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">maximumComponentLength</xsl:attribute>
				<xsl:value-of select="MaximumComponentLength" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">fileSystem</xsl:attribute>
				<xsl:value-of select="FileSystem" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">drive</xsl:attribute>
				<xsl:value-of select="Path" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">driveSource</xsl:attribute>
				<xsl:value-of select="Source" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">type</xsl:attribute>
				<xsl:value-of select="Type" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">options</xsl:attribute>
				<xsl:value-of select="Options" />
			</xsl:element>
			
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Attributes</xsl:attribute>
				
				<xsl:call-template name="DriveAttribute">
					<xsl:with-param name="flag" select="Flags/DriveFlagReadPermission"/>
					<xsl:with-param name="var" select="'readPermission'"/>
				</xsl:call-template>
				<xsl:call-template name="DriveAttribute">
					<xsl:with-param name="flag" select="Flags/DriveFlagWritePermission"/>
					<xsl:with-param name="var" select="'writePermission'"/>
				</xsl:call-template>
				<xsl:call-template name="DriveAttribute">
					<xsl:with-param name="flag" select="Flags/DriveFlagCaseSensitiveSearch"/>
					<xsl:with-param name="var" select="'caseSensitiveSearch'"/>
				</xsl:call-template>
				<xsl:call-template name="DriveAttribute">
					<xsl:with-param name="flag" select="Flags/DriveFlagCasePreservedNames"/>
					<xsl:with-param name="var" select="'casePreservedNames'"/>
				</xsl:call-template>
				<xsl:call-template name="DriveAttribute">
					<xsl:with-param name="flag" select="Flags/DriveFlagUnicodeOnDisk"/>
					<xsl:with-param name="var" select="'unicodeOnDisk'"/>
				</xsl:call-template>
				<xsl:call-template name="DriveAttribute">
					<xsl:with-param name="flag" select="Flags/DriveFlagPersistentAcls"/>
					<xsl:with-param name="var" select="'persistentAcls'"/>
				</xsl:call-template>
				<xsl:call-template name="DriveAttribute">
					<xsl:with-param name="flag" select="Flags/DriveFlagFileCompression"/>
					<xsl:with-param name="var" select="'fileCompression'"/>
				</xsl:call-template>
				<xsl:call-template name="DriveAttribute">
					<xsl:with-param name="flag" select="Flags/DriveFlagQuotas"/>
					<xsl:with-param name="var" select="'quotas'"/>
				</xsl:call-template>
				<xsl:call-template name="DriveAttribute">
					<xsl:with-param name="flag" select="Flags/DriveFlagSupportsSparseFiles"/>
					<xsl:with-param name="var" select="'supportsSparseFiles'"/>
				</xsl:call-template>
				<xsl:call-template name="DriveAttribute">
					<xsl:with-param name="flag" select="Flags/DriveFlagSupportsReparsePoints"/>
					<xsl:with-param name="var" select="'supportsReparsePoints'"/>
				</xsl:call-template>
				<xsl:call-template name="DriveAttribute">
					<xsl:with-param name="flag" select="Flags/DriveFlagSupportsRemoteStorage"/>
					<xsl:with-param name="var" select="'supportsRemoteStorage'"/>
				</xsl:call-template>
				<xsl:call-template name="DriveAttribute">
					<xsl:with-param name="flag" select="Flags/DriveFlagIsCompressed"/>
					<xsl:with-param name="var" select="'isCompressed'"/>
				</xsl:call-template>
				<xsl:call-template name="DriveAttribute">
					<xsl:with-param name="flag" select="Flags/DriveFlagSupportsObjectIds"/>
					<xsl:with-param name="var" select="'supportsObjectIds'"/>
				</xsl:call-template>
				<xsl:call-template name="DriveAttribute">
					<xsl:with-param name="flag" select="Flags/DriveFlagSupportsEncryption"/>
					<xsl:with-param name="var" select="'supportsEncryption'"/>
				</xsl:call-template>
				<xsl:call-template name="DriveAttribute">
					<xsl:with-param name="flag" select="Flags/DriveFlagSupportsNameStreams"/>
					<xsl:with-param name="var" select="'supportsNameStreams'"/>
				</xsl:call-template>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="DriveAttribute">
		<xsl:param name="flag"/>
		<xsl:param name="var" />
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">
				<xsl:value-of select="$var"/>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="$flag">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

</xsl:transform>
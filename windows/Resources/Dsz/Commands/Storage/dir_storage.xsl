<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes"/>

	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="Directories"/>
			<xsl:call-template name="TaskingInfo">
				<xsl:with-param name="info" select="TaskingInfo"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Directories">
		<xsl:apply-templates select="Directory"/>
	</xsl:template>
	
	<xsl:template match="Directory">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">DirItem</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">denied</xsl:attribute>
				<xsl:choose>
					<xsl:when test="@denied">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">path</xsl:attribute>
				<xsl:value-of select="@path"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">timestamp</xsl:attribute>
				<xsl:value-of select="../@lptimestamp"/>
			</xsl:element>
			
			<xsl:apply-templates select="File"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="File">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">FileItem</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">name</xsl:attribute>
				<xsl:value-of select="@name"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">altName</xsl:attribute>
				<xsl:value-of select="@shortName"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">size</xsl:attribute>
				<xsl:value-of select="@size"/>
			</xsl:element>
			
			<xsl:apply-templates select="FileTimes" />

			<xsl:if test="Reparse">
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">ReparseInfo</xsl:attribute>

					<xsl:element name="IntValue">
						<xsl:attribute name="name">Flags</xsl:attribute>
						<xsl:value-of select="Reparse/@flags"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">type</xsl:attribute>
						<xsl:value-of select="Reparse/@type"/>
					</xsl:element>

					<xsl:if test="Reparse/TargetPath">
						<xsl:element name="StringValue">
							<xsl:attribute name="name">TargetPath</xsl:attribute>
							<xsl:value-of select="Reparse/TargetPath"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="Reparse/AltTargetPath">
						<xsl:element name="StringValue">
							<xsl:attribute name="name">AltTargetPath</xsl:attribute>
							<xsl:value-of select="Reparse/AltTargetPath"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:if>

			<xsl:for-each select="Hash">
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">Hash</xsl:attribute>
					
					<xsl:element name="IntValue">
						<xsl:attribute name="name">Size</xsl:attribute>
						<xsl:value-of select="@size"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Type</xsl:attribute>
						<xsl:value-of select="@type"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Value</xsl:attribute>
						<xsl:value-of select="."/>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>

			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Attributes</xsl:attribute>

				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeDirectory"/>
					<xsl:with-param name="var"  select="'directory'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="AccessDenied"/>
					<xsl:with-param name="var"  select="'accessDenied'"/>
				</xsl:call-template>

				<!-- all windows stuff -->				
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeReparsePoint"/>
					<xsl:with-param name="var"  select="'reparsePoint'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeCompressed"/>
					<xsl:with-param name="var"  select="'compressed'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeArchive"/>
					<xsl:with-param name="var"  select="'archive'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeEncrypted"/>
					<xsl:with-param name="var"  select="'encrypted'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeHidden"/>
					<xsl:with-param name="var"  select="'hidden'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeOffline"/>
					<xsl:with-param name="var"  select="'offline'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeReadonly"/>
					<xsl:with-param name="var"  select="'read-only'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeSystem"/>
					<xsl:with-param name="var"  select="'system'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeTemporary"/>
					<xsl:with-param name="var"  select="'temporary'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeVirtual"/>
					<xsl:with-param name="var"  select="'virtual'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeNotIndexed"/>
					<xsl:with-param name="var"  select="'notindexed'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeDevice"/>
					<xsl:with-param name="var"  select="'device'"/>
				</xsl:call-template>
				
				<!-- unix stuff -->
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeAFUnixFamilySocket"/>
					<xsl:with-param name="var"  select="'afUnixFamilySocket'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeBlockSpecialFile"/>
					<xsl:with-param name="var"  select="'blockSpecialFile'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeCharacterSpecialFile"/>
					<xsl:with-param name="var"  select="'characterSpecialFile'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeNamedPipeFile"/>
					<xsl:with-param name="var"  select="'namedPipe'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeSymbolicLink"/>
					<xsl:with-param name="var"  select="'symbolicLink'"/>
				</xsl:call-template>
			</xsl:element>
			
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Unix-Specific</xsl:attribute>

				<xsl:element name="StringValue">
					<xsl:attribute name="name">owner</xsl:attribute>
					<xsl:value-of select="@owner"/>
				</xsl:element>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">group</xsl:attribute>
					<xsl:value-of select="@group"/>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">ownerId</xsl:attribute>
					<xsl:value-of select="@ownerId"/>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">groupId</xsl:attribute>
					<xsl:value-of select="@groupId"/>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">hardLinks</xsl:attribute>
					<xsl:value-of select="@hardLinks"/>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">inode</xsl:attribute>
					<xsl:value-of select="@inode"/>
				</xsl:element>
			
				<xsl:apply-templates select="Permissions"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Permissions">	
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Permissions</xsl:attribute>
		
			<xsl:call-template name="FileAttribute">
				<xsl:with-param name="flag" select="FilePermissionSetUid"/>
				<xsl:with-param name="var"  select="'setUid'"/>
			</xsl:call-template>
			<xsl:call-template name="FileAttribute">
			<xsl:with-param name="flag" select="FilePermissionSetGid"/>
			<xsl:with-param name="var"  select="'setGid'"/>
			</xsl:call-template>
			<xsl:call-template name="FileAttribute">
				<xsl:with-param name="flag" select="FilePermissionSticky"/>
				<xsl:with-param name="var"  select="'sticky'"/>
			</xsl:call-template>
			
			<xsl:call-template name="FileAttribute">
				<xsl:with-param name="flag" select="FilePermissionOwnerRead"/>
				<xsl:with-param name="var"  select="'ownerRead'"/>
			</xsl:call-template>
			<xsl:call-template name="FileAttribute">
				<xsl:with-param name="flag" select="FilePermissionOwnerWrite"/>
				<xsl:with-param name="var"  select="'ownerWrite'"/>
			</xsl:call-template>
			<xsl:call-template name="FileAttribute">
				<xsl:with-param name="flag" select="FilePermissionOwnerExecute"/>
				<xsl:with-param name="var"  select="'ownerExecute'"/>
			</xsl:call-template>
		
			<xsl:call-template name="FileAttribute">
				<xsl:with-param name="flag" select="FilePermissionGroupRead"/>
				<xsl:with-param name="var"  select="'groupRead'"/>
			</xsl:call-template>
			<xsl:call-template name="FileAttribute">
				<xsl:with-param name="flag" select="FilePermissionGroupWrite"/>
				<xsl:with-param name="var"  select="'groupWrite'"/>
			</xsl:call-template>
			<xsl:call-template name="FileAttribute">
				<xsl:with-param name="flag" select="FilePermissionGroupExecute"/>
				<xsl:with-param name="var"  select="'groupExecute'"/>
			</xsl:call-template>
					
			<xsl:call-template name="FileAttribute">
				<xsl:with-param name="flag" select="FilePermissionWorldRead"/>
				<xsl:with-param name="var"  select="'worldRead'"/>
			</xsl:call-template>
			<xsl:call-template name="FileAttribute">
				<xsl:with-param name="flag" select="FilePermissionWorldWrite"/>
				<xsl:with-param name="var"  select="'worldWrite'"/>
			</xsl:call-template>
			<xsl:call-template name="FileAttribute">
				<xsl:with-param name="flag" select="FilePermissionWorldExecute"/>
				<xsl:with-param name="var"  select="'worldExecute'"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="FileAttribute">
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
	
	<xsl:template match="FileTimes">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">FileTimes</xsl:attribute>
			
				<xsl:call-template name="FileTimeFunction">
					<xsl:with-param name="time" select="Modified"/>
					<xsl:with-param name="var"  select="'Modified'"/>
				</xsl:call-template>
				<xsl:call-template name="FileTimeFunction">
					<xsl:with-param name="time" select="Accessed"/>
					<xsl:with-param name="var"  select="'Accessed'"/>
				</xsl:call-template>
				<xsl:call-template name="FileTimeFunction">
					<xsl:with-param name="time" select="Created"/>
					<xsl:with-param name="var"  select="'Created'"/>
				</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="FileTimeFunction">
		<xsl:param name="time"/>
		<xsl:param name="var" />
		
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">
				<xsl:value-of select="$var"/>
			</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">time</xsl:attribute>
				<xsl:value-of select="$time"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">type</xsl:attribute>
				<xsl:value-of select="$time/@type"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:transform>

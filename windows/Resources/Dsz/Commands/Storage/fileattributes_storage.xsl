<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates select="FileAttribs"/>
			<xsl:apply-templates select="OriginalFileAttribs"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="FileAttribs">
		<xsl:call-template name="StoreFileAttribs"/>
	</xsl:template>
	
	<xsl:template match="OriginalFileAttribs">
		<xsl:call-template name="StoreFileAttribs"/>
	</xsl:template>

	
	<xsl:template name="StoreFileAttribs">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">File</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Name</xsl:attribute>
				<xsl:value-of select="@file"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Size</xsl:attribute>
				<xsl:value-of select="@size"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Owner</xsl:attribute>
				<xsl:value-of select="@owner"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Group</xsl:attribute>
				<xsl:value-of select="@group"/>
			</xsl:element>
			
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Attributes</xsl:attribute>
			
				<xsl:call-template name="StoreAttributes"/>
			</xsl:element>
			
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
				<xsl:attribute name="name">date</xsl:attribute>
				<xsl:value-of select="substring-before($time, 'T')"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">time</xsl:attribute>
				<xsl:value-of select="substring-after($time, 'T')"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">type</xsl:attribute>
				<xsl:value-of select="$time/@type"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="StoreAttributes">
		<xsl:element name="IntValue">
			<xsl:attribute name="name">Value</xsl:attribute>
			<xsl:value-of select="@attributeMask"/>
		</xsl:element>
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">Archive</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_ARCHIVE">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>     
			</xsl:choose>
		</xsl:element>

		<xsl:element name="BoolValue">
			<xsl:attribute name="name">Compressed</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_COMPRESSED">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>     
			</xsl:choose>
		</xsl:element>
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">Directory</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_DIRECTORY">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>     
			</xsl:choose>
		</xsl:element>
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">Encrypted</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_ENCRYPTED">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>     
			</xsl:choose>
		</xsl:element>
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">Hidden</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_HIDDEN">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>     
			</xsl:choose>
		</xsl:element>
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">Normal</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_NORMAL">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>     
			</xsl:choose>
		</xsl:element>
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">Offline</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_OFFLINE">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>     
			</xsl:choose>
		</xsl:element>
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">Read-Only</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_READONLY">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>     
			</xsl:choose>
		</xsl:element>
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">ReadOnly</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_READONLY">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>

		<xsl:element name="BoolValue">
			<xsl:attribute name="name">ReparsePoint</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_REPARSE_POINT">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>     
			</xsl:choose>
		</xsl:element>
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">SparseFile</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_SPARSE_FILE">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>     
			</xsl:choose>
		</xsl:element>
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">System</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_SYSTEM">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>     
			</xsl:choose>
		</xsl:element>
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">Temporary</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_TEMPORARY">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>     
			</xsl:choose>
		</xsl:element>
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">NotContentIndexed</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_NOT_CONTENT_INDEXED">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>     
			</xsl:choose>
		</xsl:element>
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">Device</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_DEVICE">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>     
			</xsl:choose>
		</xsl:element>
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">OwnerRead</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_OWNER_READ">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>     
			</xsl:choose>
		</xsl:element>
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">OwnerWrite</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_OWNER_WRITE">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>     
			</xsl:choose>
		</xsl:element>
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">OwnerExecute</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_OWNER_EXEC">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>     
			</xsl:choose>
		</xsl:element>
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">GroupRead</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_GROUP_READ">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>     
			</xsl:choose>
		</xsl:element>
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">GroupWrite</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_GROUP_WRITE">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>     
			</xsl:choose>
		</xsl:element>
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">GroupExecute</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_GROUP_EXEC">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>     
			</xsl:choose>
		</xsl:element>
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">WorldRead</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_WORLD_READ">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>     
			</xsl:choose>
		</xsl:element>
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">WorldWrite</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_WORLD_WRITE">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>     
			</xsl:choose>
		</xsl:element>
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">WorldExecute</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_WORLD_EXEC">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>     
			</xsl:choose>
		</xsl:element>
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">SetUid</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_SET_UID">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>     
			</xsl:choose>
		</xsl:element>
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">SetGid</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_SET_GID">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>     
			</xsl:choose>
		</xsl:element>
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">Sticky</xsl:attribute>
			<xsl:choose>
				<xsl:when test="FILE_ATTRIBUTE_STICKY_BIT">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>     
			</xsl:choose>
		</xsl:element>
		
	</xsl:template>
	
</xsl:transform>

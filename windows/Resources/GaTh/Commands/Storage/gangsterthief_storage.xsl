<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name = "StorageObjects">
			<xsl:apply-templates select = "GangsterThiefFileListEntries"/>
			<xsl:apply-templates select = "GangsterThiefFileInformation"/>
			<xsl:apply-templates select = "FileStart"/>
			<xsl:apply-templates select="FileLocalName"/> 
			<xsl:apply-templates select="FileWrite"/> 
			<xsl:apply-templates select="FileStop"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="GangsterThiefFileListEntries">
		<xsl:apply-templates select="GangsterThiefFileListEntry" />
		<xsl:element name="IntValue">
				<xsl:attribute name="name">EntryCount</xsl:attribute>
				<xsl:value-of select="@EntryCount" />
		</xsl:element>
	</xsl:template>
	<xsl:template match="GangsterThiefFileListEntry">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">FileListEntry</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">filename</xsl:attribute>
				<xsl:value-of select="@filename" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">recordindex</xsl:attribute>
				<xsl:value-of select="@recordindex" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">parentrecordindex</xsl:attribute>
				<xsl:value-of select="@parentrecordindex" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">filesize</xsl:attribute>
				<xsl:value-of select="@filesize" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">filesizeondisk</xsl:attribute>
				<xsl:value-of select="@filesizeondisk" />
			</xsl:element>
			<xsl:call-template name="FileTimeFunction">
				<xsl:with-param name="time" select="StdCreated"/>
				<xsl:with-param name="var"  select="'StdCreated'"/>
			</xsl:call-template>
			<xsl:call-template name="FileTimeFunction">
				<xsl:with-param name="time" select="FileNameCreated"/>
				<xsl:with-param name="var"  select="'FileNameCreated'"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="GangsterThiefFileInformation">
		<xsl:apply-templates select="GangsterThiefFileInformationEntry" />
	</xsl:template>
	<xsl:template match="GangsterThiefFileInformationEntry">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">FileInfoEntry</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">filename</xsl:attribute>
				<xsl:value-of select="@filename" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">recordindex</xsl:attribute>
				<xsl:value-of select="@recordindex" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">filesize</xsl:attribute>
				<xsl:value-of select="@filesize" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">filesizeondisk</xsl:attribute>
				<xsl:value-of select="@filesizeondisk" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">dosflags</xsl:attribute>
				<xsl:value-of select="@dosflags" />
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">filenameflags</xsl:attribute>
				<xsl:value-of select="@filenameflags" />
			</xsl:element>					
			<xsl:element name="IntValue">
				<xsl:attribute name="name">overwrittenpercentage</xsl:attribute>
				<xsl:value-of select="@overwrittenpercentage" />
			</xsl:element>	
			<xsl:element name="IntValue">
				<xsl:attribute name="name">parentrecordindex</xsl:attribute>
				<xsl:value-of select="@parentrecordindex" />
			</xsl:element>				
			
			<xsl:apply-templates select="MACEFileTimes" />
			
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Attributes</xsl:attribute>

				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeDeleted"/>
					<xsl:with-param name="var"  select="'deleted'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeDir"/>
					<xsl:with-param name="var"  select="'directory'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeSystem"/>
					<xsl:with-param name="var"  select="'system'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeArchive"/>
					<xsl:with-param name="var"  select="'archive'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeDevice"/>
					<xsl:with-param name="var"  select="'device'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeNormal"/>
					<xsl:with-param name="var"  select="'normal'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeTemporary"/>
					<xsl:with-param name="var"  select="'temporary'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeSparseFile"/>
					<xsl:with-param name="var"  select="'sparse'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeReparsePoint"/>
					<xsl:with-param name="var"  select="'reparsepoint'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeCompressed"/>
					<xsl:with-param name="var"  select="'compressed'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeOffline"/>
					<xsl:with-param name="var"  select="'offline'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeNotIndexed"/>
					<xsl:with-param name="var"  select="'notindexed'"/>
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
					<xsl:with-param name="flag" select="FileAttributeReadonly"/>
					<xsl:with-param name="var"  select="'read-only'"/>
				</xsl:call-template>
				<xsl:call-template name="FileAttribute">
					<xsl:with-param name="flag" select="FileAttributeInUse"/>
					<xsl:with-param name="var"  select="'inuse'"/>
				</xsl:call-template>					
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template match="MACEFileTimes">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">MACEFileTimes</xsl:attribute>
			
				<xsl:call-template name="FileTimeFunction">
					<xsl:with-param name="time" select="StdModified"/>
					<xsl:with-param name="var"  select="'StdModified'"/>
				</xsl:call-template>
				<xsl:call-template name="FileTimeFunction">
					<xsl:with-param name="time" select="StdAccessed"/>
					<xsl:with-param name="var"  select="'StdAccessed'"/>
				</xsl:call-template>
				<xsl:call-template name="FileTimeFunction">
					<xsl:with-param name="time" select="StdCreated"/>
					<xsl:with-param name="var"  select="'StdCreated'"/>
				</xsl:call-template>
				<xsl:call-template name="FileTimeFunction">
					<xsl:with-param name="time" select="StdEntry"/>
					<xsl:with-param name="var"  select="'StdEntry'"/>
				</xsl:call-template>
				<xsl:call-template name="FileTimeFunction">
					<xsl:with-param name="time" select="FilenameModified"/>
					<xsl:with-param name="var"  select="'FilenameModified'"/>
				</xsl:call-template>
				<xsl:call-template name="FileTimeFunction">
					<xsl:with-param name="time" select="FilenameAccessed"/>
					<xsl:with-param name="var"  select="'FilenameAccessed'"/>
				</xsl:call-template>
				<xsl:call-template name="FileTimeFunction">
					<xsl:with-param name="time" select="FilenameCreated"/>
					<xsl:with-param name="var"  select="'FilenameCreated'"/>
				</xsl:call-template>
				<xsl:call-template name="FileTimeFunction">
					<xsl:with-param name="time" select="FilenameEntry"/>
					<xsl:with-param name="var"  select="'FilenameEntry'"/>
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

	<xsl:template match="LocalGetDirectory">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">LocalGetDirectory</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">path</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="FileStart">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">FileStart</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">FileName</xsl:attribute>
				<xsl:variable name="realpath" select="@realPath"/>
				<xsl:choose>
					<xsl:when test="string($realpath)">
						<xsl:value-of select="$realpath"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@remoteName"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">OriginalName</xsl:attribute>
				<xsl:value-of select="@remoteName"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Size</xsl:attribute>
				<xsl:value-of select="@size"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">id</xsl:attribute>
				<xsl:value-of select="@fileId"/>
			</xsl:element>
			
			<xsl:apply-templates select="FileTimes"/>
			<xsl:apply-templates select="GangsterThiefFileInformationEntry" />
			
		</xsl:element>
	</xsl:template>

	<xsl:template match="FileLocalName">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">FileLocalName</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">LocalName</xsl:attribute>
				<xsl:value-of select="."/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Subdir</xsl:attribute>
				<xsl:value-of select="@subdir"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">id</xsl:attribute>
				<xsl:value-of select="@fileId"/>
			</xsl:element>
			
		</xsl:element>
	</xsl:template>

	<xsl:template match="FileWrite">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">FileWrite</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">id</xsl:attribute>
				<xsl:value-of select="@fileId"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">bytes</xsl:attribute>
				<xsl:value-of select="@bytes"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">totalBytes</xsl:attribute>
				<xsl:value-of select="@totalBytes"/>
			</xsl:element>

		</xsl:element>
	</xsl:template>

	<xsl:template match="FileStop">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">FileStop</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">id</xsl:attribute>
				<xsl:value-of select="@fileId"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">written</xsl:attribute>
				<xsl:value-of select="@bytesWritten"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">Successful</xsl:attribute>
				<xsl:choose>
					<xsl:when test="starts-with(@status, 'SUCCESS')">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			
		</xsl:element>
	</xsl:template>

	<xsl:template match="Conclusion">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Conclusion</xsl:attribute>
		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NumSuccess</xsl:attribute>
				<xsl:value-of select="@successFiles"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NumPartial</xsl:attribute>
				<xsl:value-of select="@partialFiles"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NumFailed</xsl:attribute>
				<xsl:value-of select="@failedFiles"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NumSkipped</xsl:attribute>
				<xsl:value-of select="@skippedFiles"/>
			</xsl:element>
			
		</xsl:element>
	</xsl:template>


	<!-- This template takes advantage of the below functionality -->

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
	

</xsl:transform>
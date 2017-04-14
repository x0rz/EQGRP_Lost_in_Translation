<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
	<xsl:template match="GangsterThiefFileListEntries">
		<xsl:call-template name="PrintReturn" />
		<xsl:text>-----------------------------------------------------------------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Record Index   Size  Std Create Time					Filename Create Time</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>-----------------------------------------------------------------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn" />
		
		<xsl:apply-templates select="GangsterThiefFileListEntry"/>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    </xsl:text>
		<xsl:value-of select="@EntryCount" />
		<xsl:text> files returned</xsl:text>
		<xsl:call-template name="PrintReturn" />
		
	   
	</xsl:template>
	
	<xsl:template match="GangsterThiefFileListEntry">
		<xsl:value-of select="@filename" />
		<xsl:call-template name="PrintReturn" />
		<xsl:value-of select="@recordindex" />
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="11 - string-length(@recordindex)"/>
		</xsl:call-template>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="8 - string-length(@filesize)"/>
		</xsl:call-template>

		<xsl:value-of select="@filesize" />
		<xsl:text>  </xsl:text>
		<xsl:value-of select="StdCreated" />
		<xsl:text>	</xsl:text>
		<xsl:value-of select="FileNameCreated" />
		<xsl:text>	</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:call-template name="PrintReturn" />
		
	</xsl:template>
	
	<xsl:template match="FileLocalName">
	<xsl:text>    Storing to : </xsl:text>
	<xsl:value-of select="@subdir"/>
	<xsl:text>/</xsl:text>
	<xsl:value-of select="."/>
	<xsl:call-template name="PrintReturn"/>
	
	</xsl:template>
	<xsl:template match="GangsterThiefFileInformation">
		<!--<xsl:call-template name="GangsterThiefFileInformationEntry">
			<xsl:with-param name="entry" select="."/>
		</xsl:call-template>-->
	   <xsl:apply-templates select="GangsterThiefFileInformationEntry"/>
	</xsl:template>
	<xsl:template match="GangsterThiefFileInformationEntry">
		<xsl:param name="entry"/>

		<xsl:call-template name="PrintReturn" />
		<xsl:text>-----------------------------------------------------------------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Record Index: </xsl:text>
		<xsl:value-of select="@recordindex" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>-----------------------------------------------------------------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>file path : </xsl:text>
		<xsl:value-of select="@filename" />
		<xsl:call-template name="PrintReturn" />
		<xsl:choose>
			<xsl:when test="FileAttributeDir"><xsl:text>This is a directory</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>This is a file</xsl:text></xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn" />
		<xsl:choose>
			<xsl:when test="FileAttributeDeleted">
				<xsl:text>File has been deleted</xsl:text>
				<xsl:choose>
					<xsl:when test="FileAttributeInUse">
						<xsl:text> and overwritten</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text> but has not been overwritten and can be recovered</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="(101 > number(@overwrittenpercentage) )">
						<xsl:text>- </xsl:text>
						<xsl:value-of select="@overwrittenpercentage" />
						<xsl:text>% of file overwritten</xsl:text>
					</xsl:when>
				</xsl:choose>

				<xsl:call-template name="PrintReturn" />
			</xsl:when>
		</xsl:choose>
				
		<xsl:text>file size : </xsl:text>
		<xsl:value-of select="@filesize" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>file size on disk : </xsl:text>
		<xsl:value-of select="@filesizeondisk" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Parent record index : </xsl:text>
		<xsl:value-of select="@parentrecordindex" />
		<xsl:call-template name="PrintReturn" />
		<xsl:call-template name="PrintReturn" />
	   

		<xsl:apply-templates select="MACEFileTimes" />
		
		<xsl:text>Dos File attributes: </xsl:text>
		<xsl:choose>
			<xsl:when test="FileAttributeArchive"><xsl:text>A</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>-</xsl:text></xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="FileAttributeCompressed"><xsl:text>C</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>-</xsl:text></xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="FileAttributeEncrypted"><xsl:text>E</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>-</xsl:text></xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="FileAttributeHidden"><xsl:text>H</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>-</xsl:text></xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="FileAttributeOffline"><xsl:text>O</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>-</xsl:text></xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="FileAttributeReadonly"><xsl:text>R</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>-</xsl:text></xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="FileAttributeSystem"><xsl:text>S</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>-</xsl:text></xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="FileAttributeTemporary"><xsl:text>T</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>-</xsl:text></xsl:otherwise>
		</xsl:choose>
		
		
		
		<xsl:call-template name="PrintReturn" />
 
		<xsl:call-template name="PrintReturn" /> 
	</xsl:template>
	
	
	<xsl:template match="MACEFileTimes">
		<xsl:text>Modified                        Accessed                        Created                         Entry</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>-----------------------------------------------------------------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Standard file times: </xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:value-of select="StdModified" />
		<xsl:text>   </xsl:text>
		<xsl:value-of select="StdAccessed" />
		<xsl:text>   </xsl:text>
		<xsl:value-of select="StdCreated" />
		<xsl:text>   </xsl:text>
		<xsl:value-of select="StdEntry" />
		<xsl:text>   </xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>NTFS File name times: </xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:value-of select="FilenameModified" />
		<xsl:text>   </xsl:text>
		<xsl:value-of select="FilenameAccessed" />
		<xsl:text>   </xsl:text>
		<xsl:value-of select="FilenameCreated" />
		<xsl:text>   </xsl:text>
		<xsl:value-of select="FilenameEntry" />
		<xsl:text>   </xsl:text>
		<xsl:call-template name="PrintReturn" />
		

		<xsl:call-template name="PrintReturn" />
		
	</xsl:template>

  
	<xsl:template match="FileStart">
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Receiving file </xsl:text>
		<xsl:value-of select="@fileId"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    </xsl:text>
		<xsl:value-of select="@remoteName"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    Size : </xsl:text>
		<xsl:value-of select="@size"/>
		<xsl:text> bytes</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:choose>
			<xsl:when test="GangsterThiefFileInformationEntry/FileAttributeEncrypted">
				<xsl:text>===Warning file is encrypted by NTFS===</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:when>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="GangsterThiefFileInformationEntry/FileAttributeCompressed">
				<xsl:text>===Warning file is compressed by NTFS===</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="LocalGetDirectory" />
 
	<xsl:template match="FileLocalName">
		<xsl:text>    Storing to : </xsl:text>
		<xsl:value-of select="@subdir"/>
		<xsl:text>/</xsl:text>
		<xsl:value-of select="."/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="FileWrite">
		<xsl:text>Writing </xsl:text>
		<xsl:value-of select="@bytes"/>
		<xsl:text> bytes - (total </xsl:text>
		<xsl:value-of select="@totalBytes"/>
		<xsl:text> bytes)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		
	</xsl:template>

	<xsl:template match="FileStop">
		<xsl:if test="@status = 'SUCCESS'">
			<xsl:text>    File get operation succeeded</xsl:text>
		    <xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="@status = 'SKIPPED'">
			<xsl:text>    File get operation skipped</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:text>    Stored: </xsl:text>
		<xsl:value-of select="@bytesWritten"/>
		<xsl:text> (</xsl:text>
		<xsl:value-of select="@status"/>
		<xsl:if test="@statusValue">
			<xsl:text> - </xsl:text>
			<xsl:value-of select="@statusValue"/>
		</xsl:if>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:if test="StatusString">
			<xsl:text>      (</xsl:text>
			<xsl:value-of select="StatusString"/>
			<xsl:text>)</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="Conclusion">
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:value-of select="@successFiles" />
		<xsl:text> Files retrieved.</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:value-of select="@partialFiles" />
		<xsl:text> Partial Files retrieved.</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:value-of select="@failedFiles" />
		<xsl:text> Files transfers failed.</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:value-of select="@skippedFiles" />
		<xsl:text> Files skipped. </xsl:text>
		<xsl:call-template name = "PrintReturn" />
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Total bytes written </xsl:text>
		<xsl:value-of select="@bytesTransferred" />
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

</xsl:transform>
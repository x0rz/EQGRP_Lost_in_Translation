<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
	
	<xsl:template match="OriginalFileAttribs">
		<xsl:text>File attributes changed for </xsl:text>
		<xsl:value-of select="@file"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="FileAttribs">

		<xsl:text>File: </xsl:text>
		<xsl:value-of select="@file"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>         Size : </xsl:text>
		<xsl:value-of select="@size"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:if test="@owner">
			<xsl:text>         Owner : </xsl:text>
			<xsl:value-of select="@owner"/>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>

		<xsl:if test="@group">
			<xsl:text>         Group : </xsl:text>
			<xsl:value-of select="@group"/>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>

		<xsl:call-template name="PrintReturn"/>

		<xsl:text>   Attributes : (</xsl:text>
		<xsl:value-of select="@attributeMask"/>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
  
		<xsl:if test="FILE_ATTRIBUTE_ARCHIVE">
			<xsl:text>        FILE_ATTRIBUTE_ARCHIVE</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="FILE_ATTRIBUTE_COMPRESSED">
			<xsl:text>        FILE_ATTRIBUTE_COMPRESSED</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="FILE_ATTRIBUTE_DIRECTORY">
			<xsl:text>        FILE_ATTRIBUTE_DIRECTORY</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="FILE_ATTRIBUTE_ENCRYPTED">
			<xsl:text>        FILE_ATTRIBUTE_ENCRYPTED</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="FILE_ATTRIBUTE_HIDDEN">
			<xsl:text>        FILE_ATTRIBUTE_HIDDEN</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="FILE_ATTRIBUTE_NORMAL">
			<xsl:text>        FILE_ATTRIBUTE_NORMAL</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="FILE_ATTRIBUTE_OFFLINE">
			<xsl:text>        FILE_ATTRIBUTE_OFFLINE</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="FILE_ATTRIBUTE_READONLY">
			<xsl:text>        FILE_ATTRIBUTE_READONLY</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="FILE_ATTRIBUTE_REPARSE_POINT">
			<xsl:text>        FILE_ATTRIBUTE_REPARSE_POINT</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="FILE_ATTRIBUTE_SPARSE_FILE">
			<xsl:text>        FILE_ATTRIBUTE_SPARSE_FILE</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="FILE_ATTRIBUTE_SYSTEM">
			<xsl:text>        FILE_ATTRIBUTE_SYSTEM</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="FILE_ATTRIBUTE_TEMPORARY">
			<xsl:text>        FILE_ATTRIBUTE_TEMPORARY</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="FILE_ATTRIBUTE_NOT_CONTENT_INDEXED">
			<xsl:text>        FILE_ATTRIBUTE_NOT_CONTENT_INDEXED</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="FILE_ATTRIBUTE_DEVICE">
			<xsl:text>        FILE_ATTRIBUTE_DEVICE</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="FILE_ATTRIBUTE_OWNER_READ">
			<xsl:text>        FILE_ATTRIBUTE_OWNER_READ</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="FILE_ATTRIBUTE_OWNER_WRITE">
			<xsl:text>        FILE_ATTRIBUTE_OWNER_WRITE</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="FILE_ATTRIBUTE_OWNER_EXEC">
			<xsl:text>        FILE_ATTRIBUTE_OWNER_EXEC</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="FILE_ATTRIBUTE_GROUP_READ">
			<xsl:text>        FILE_ATTRIBUTE_GROUP_READ</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="FILE_ATTRIBUTE_GROUP_WRITE">
			<xsl:text>        FILE_ATTRIBUTE_GROUP_WRITE</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="FILE_ATTRIBUTE_GROUP_EXEC">
			<xsl:text>        FILE_ATTRIBUTE_GROUP_EXEC</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="FILE_ATTRIBUTE_WORLD_READ">
			<xsl:text>        FILE_ATTRIBUTE_WORLD_READ</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="FILE_ATTRIBUTE_WORLD_WRITE">
			<xsl:text>        FILE_ATTRIBUTE_WORLD_WRITE</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="FILE_ATTRIBUTE_WORLD_EXEC">
			<xsl:text>        FILE_ATTRIBUTE_WORLD_EXEC</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="FILE_ATTRIBUTE_SET_UID">
			<xsl:text>        FILE_ATTRIBUTE_SET_UID</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="FILE_ATTRIBUTE_SET_GID">
			<xsl:text>        FILE_ATTRIBUTE_SET_GID</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="FILE_ATTRIBUTE_STICKY_BIT">
			<xsl:text>        FILE_ATTRIBUTE_STICKY_BIT</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:call-template name="PrintReturn"/>
		
		
		<xsl:text> Created Time : </xsl:text>
		<xsl:call-template name="printTimeMDYHMS">
			<xsl:with-param name="i" select="Created"/>
		</xsl:call-template>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>Accessed Time : </xsl:text>
		<xsl:call-template name="printTimeMDYHMS">
			<xsl:with-param name="i" select="Accessed"/>
		</xsl:call-template>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>Modified Time : </xsl:text>
		<xsl:call-template name="printTimeMDYHMS">
			<xsl:with-param name="i" select="Modified"/>
		</xsl:call-template>
		<xsl:call-template name="PrintReturn"/>

		<xsl:call-template name="PrintReturn"/>
		<xsl:if test="Reparse">
			<xsl:text> Reparse Type : </xsl:text>
			<xsl:value-of select="Reparse/@type"/>
			<xsl:call-template name="PrintReturn"/>
			<xsl:if test="Reparse/TargetPath and (string-length(Reparse/TargetPath) &gt; 0)">
				<xsl:text>       Target : </xsl:text>
				<xsl:value-of select="Reparse/TargetPath"/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:if>
			<xsl:if test="Reparse/AltTargetPath and (string-length(Reparse/AltTargetPath) &gt; 0)">
				<xsl:text>    AltTarget : </xsl:text>
				<xsl:value-of select="Reparse/AltTargetPath"/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:if>
			<xsl:text>  Reparse Tag : (</xsl:text>
			<xsl:value-of select="Reparse/@flags"/>
			<xsl:text>)</xsl:text>
			<xsl:call-template name="PrintReturn"/>
			<xsl:if test="Reparse/FILE_REPARSE_FLAG_SURROGATE">
				<xsl:text>        FILE_REPARSE_FLAG_SURROGATE</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:if>
			<xsl:if test="Reparse/FILE_REPARSE_FLAG_MOUNT_POINT">
				<xsl:text>        FILE_REPARSE_FLAG_MOUNT_POINT</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:if>
			<xsl:if test="Reparse/FILE_REPARSE_FLAG_MICROSOFT_HSM">
				<xsl:text>        FILE_REPARSE_FLAG_MICROSOFT_HSM</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:if>
			<xsl:if test="Reparse/FILE_REPARSE_FLAG_MICROSOFT_SIS">
				<xsl:text>        FILE_REPARSE_FLAG_MICROSOFT_SIS</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:if>
			<xsl:if test="Reparse/FILE_REPARSE_FLAG_MICROSOFT_DFS">
				<xsl:text>        FILE_REPARSE_FLAG_MICROSOFT_DFS</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:if>
			<xsl:if test="Reparse/FILE_REPARSE_FLAG_SYMLINK">
				<xsl:text>        FILE_REPARSE_FLAG_SYMLINK</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:if>
			<xsl:if test="Reparse/FILE_REPARSE_FLAG_DFSR">
				<xsl:text>        FILE_REPARSE_FLAG_DFSR</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:if>
			<xsl:if test="Reparse/Identifier">
				<xsl:text>    GUID : (</xsl:text>
				<xsl:value-of select="Reparse/Identifier"/>
				<xsl:text>)</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:if>
		</xsl:if>
		
	</xsl:template>

</xsl:transform>

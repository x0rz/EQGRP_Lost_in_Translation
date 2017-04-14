<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:import href="include/StandardTransforms.xsl"/>

<xsl:param name="timetype" select="'Modified'"/>

<xsl:template match="Directories">
	<xsl:apply-templates select="Directory"/>
</xsl:template>

<xsl:template match="Directory">
	<xsl:call-template name="PrintReturn"/>
	<xsl:text>Directory : </xsl:text>
	<xsl:value-of select="@path"/>
	<xsl:call-template name="PrintReturn"/>
	<xsl:call-template name="PrintReturn"/>

	<xsl:choose>
		<xsl:when test="@denied = 'true'">
			<xsl:text>    ACCESS_DENIED</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="File"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="File">

	<xsl:choose>
		<xsl:when test="@inode">
			<!-- unix file -->
			<xsl:call-template name="UnixFile">
				<xsl:with-param name="file" select="."/>
				<xsl:with-param name="timeType"><xsl:value-of select="$timetype"/></xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<!-- windows file -->
			<xsl:call-template name="WindowsFile">
				<xsl:with-param name="file" select="."/>
				<xsl:with-param name="timeType"><xsl:value-of select="$timetype"/></xsl:with-param>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>

	<xsl:for-each select="Hash">
		<xsl:if test="(number(@size) > 0)">
			<xsl:call-template name="Whitespace">
				<xsl:with-param name="i" select="8 - string-length(@type)"/>
			</xsl:call-template>
			<xsl:value-of select="@type"/>
			<xsl:text>: </xsl:text>
			<xsl:call-template name="Spaceout">
				<xsl:with-param name="i" select="8"/>
				<xsl:with-param name="string" select="."/>
			</xsl:call-template>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
	</xsl:for-each>

</xsl:template>

<xsl:template match="Success">
	<xsl:call-template name="PrintReturn"/>
	<xsl:text>Directory listing complete</xsl:text>
	<xsl:call-template name="PrintReturn"/>
</xsl:template>

<xsl:template name="UnixFile">
	<xsl:param name="file"/>
	<xsl:param name="timeType"/>

	<!-- print permissions -->
	<xsl:choose>
		<xsl:when test="$file/FileAttributeDirectory">d</xsl:when>
		<xsl:when test="$file/FileAttributeSymbolicLink">l</xsl:when>
		<xsl:when test="$file/FileAttributeBlockSpecialFile">b</xsl:when>
		<xsl:when test="$file/FileAttributeCharacterSpecialFile">c</xsl:when>
		<xsl:when test="$file/FileAttributeNamedPipeFile">p</xsl:when>
		<xsl:when test="$file/FileAttributeAFUnixFamilySocket">s</xsl:when>
		<xsl:otherwise>-</xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
		<xsl:when test="$file/Permissions/FilePermissionOwnerRead">r</xsl:when>
		<xsl:otherwise>-</xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
		<xsl:when test="$file/Permissions/FilePermissionOwnerWrite">w</xsl:when>
		<xsl:otherwise>-</xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
		<xsl:when test="$file/Permissions/FilePermissionOwnerExecute">
			<xsl:choose>
				<xsl:when test="$file/Permissions/FilePermissionSetUid">s</xsl:when>
				<xsl:otherwise>x</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:choose>
				<xsl:when test="$file/Permissions/FilePermissionSetUid">S</xsl:when>
				<xsl:otherwise>-</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
		<xsl:when test="$file/Permissions/FilePermissionGroupRead">r</xsl:when>
		<xsl:otherwise>-</xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
		<xsl:when test="$file/Permissions/FilePermissionGroupWrite">w</xsl:when>
		<xsl:otherwise>-</xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
		<xsl:when test="$file/Permissions/FilePermissionGroupExecute">
			<xsl:choose>
				<xsl:when test="$file/Permissions/FilePermissionSetGid">s</xsl:when>
				<xsl:otherwise>x</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:choose>
				<xsl:when test="$file/Permissions/FilePermissionSetGid">S</xsl:when>
				<xsl:otherwise>-</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
		<xsl:when test="$file/Permissions/FilePermissionWorldRead">r</xsl:when>
		<xsl:otherwise>-</xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
		<xsl:when test="$file/Permissions/FilePermissionWorldWrite">w</xsl:when>
		<xsl:otherwise>-</xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
		<xsl:when test="$file/Permissions/FilePermissionWorldExecute">
			<xsl:choose>
				<xsl:when test="$file/Permissions/FilePermissionSticky">t</xsl:when>
				<xsl:otherwise>x</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:choose>
				<xsl:when test="$file/Permissions/FilePermissionSticky">T</xsl:when>
				<xsl:otherwise>-</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>

	<!-- print number of links -->
	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="3 - string-length($file/@hardLinks)"/>
	</xsl:call-template>
	<xsl:value-of select="$file/@hardLinks"/>
	<xsl:text> </xsl:text>

	<!-- print owner and group -->
	<xsl:value-of select="$file/@owner"/>
	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="8 - string-length($file/@owner)"/>
	</xsl:call-template>
	<xsl:value-of select="$file/@group"/>
	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="8 - string-length($file/@group)"/>
	</xsl:call-template>

	<!-- print file size -->
	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="9 - string-length($file/@size)"/>
	</xsl:call-template>
	<xsl:value-of select="$file/@size"/>

	<!-- print file time -->
	<xsl:text> </xsl:text>
	<xsl:for-each select="$file/FileTimes/child::*">
		<xsl:if test="name(.) = $timeType">
			<xsl:variable name="time" select="."/>
			<xsl:value-of select="substring-before($time, 'T')"/>
   			<xsl:text> </xsl:text>
		   	<xsl:value-of select="substring-before(substring-after($time, 'T'), '.')"/>
		   	<xsl:text> </xsl:text>
		</xsl:if>
	</xsl:for-each>

	<!-- print file name -->
	<xsl:text> </xsl:text>
	<xsl:value-of select="$file/@name"/>

	<xsl:if test="$file/FileAttributeLink">
		<xsl:text> -> </xsl:text>
		<xsl:value-of select="$file/@altName"/>
	</xsl:if>
	<xsl:call-template name="PrintReturn"/>
</xsl:template>

<xsl:template name="WindowsFile">
	<xsl:param name="file"/>
	<xsl:param name="timeType"/>

	<!-- print time -->
	<xsl:for-each select="$file/FileTimes/child::*">
		<xsl:if test="name(.) = $timeType">
			<xsl:variable name="time" select="."/>
			<xsl:value-of select="substring-before($time, 'T')"/>
   			<xsl:text> </xsl:text>
		   	<xsl:value-of select="substring-before(substring-after($time, 'T'), '.')"/>
		   	<xsl:text> </xsl:text>
		</xsl:if>
	</xsl:for-each>

	<xsl:choose>
		<xsl:when test="$file/FileAttributeArchive"><xsl:text>A</xsl:text></xsl:when>
		<xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
		<xsl:when test="$file/FileAttributeCompressed"><xsl:text>C</xsl:text></xsl:when>
		<xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
		<xsl:when test="$file/FileAttributeEncrypted"><xsl:text>E</xsl:text></xsl:when>
		<xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
		<xsl:when test="$file/FileAttributeHidden"><xsl:text>H</xsl:text></xsl:when>
		<xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
		<xsl:when test="$file/FileAttributeOffline"><xsl:text>O</xsl:text></xsl:when>
		<xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
		<xsl:when test="$file/FileAttributeReadonly"><xsl:text>R</xsl:text></xsl:when>
		<xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
		<xsl:when test="$file/FileAttributeSystem"><xsl:text>S</xsl:text></xsl:when>
		<xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
		<xsl:when test="$file/FileAttributeTemporary"><xsl:text>T</xsl:text></xsl:when>
		<xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
	</xsl:choose>



	<xsl:choose>
	    <xsl:when test="$file/FileAttributeReparsePoint">
			<xsl:text>&lt;JUNCTION&gt;</xsl:text>
			<xsl:call-template name="Whitespace">
				<xsl:with-param name="i" select="4"/>
			</xsl:call-template>
	    </xsl:when>
	    <xsl:when test="$file/FileAttributeDirectory">
		<xsl:text>&lt;DIR&gt;</xsl:text>
		<xsl:call-template name="Whitespace">
		    <xsl:with-param name="i" select="9"/>
		</xsl:call-template>
	    </xsl:when>
	    
	    <xsl:otherwise>
	    <xsl:variable name="number">
			<xsl:call-template name="PrintNumberWithCommas">
				<xsl:with-param name="number" select="$file/@size" />
			</xsl:call-template>
	    </xsl:variable>
		<xsl:call-template name="Whitespace">
		    <xsl:with-param name="i" select="14 - string-length($number)"/>
		</xsl:call-template>
		<xsl:value-of select="$number"/>
	    </xsl:otherwise>
	</xsl:choose>

	<xsl:text> </xsl:text>

	<xsl:call-template name="Whitespace">
    	    <xsl:with-param name="i" select="12 - string-length($file/@shortName)"/>
	</xsl:call-template>

	<xsl:value-of select="$file/@shortName"/>

	<xsl:text> </xsl:text>

	<xsl:value-of select="$file/@name"/>

	<xsl:if test="$file/Reparse">
		<xsl:text> -> </xsl:text>
		<xsl:choose>
			<xsl:when test="$file/Reparse/TargetPath and (string-length($file/Reparse/TargetPath) &gt; 0)"> <!--  and string-length($file/Reparse/TargetLength/.) &gt; 0 -->
				<xsl:value-of select="$file/Reparse/TargetPath"/>
			</xsl:when>
			<xsl:when test="$file/Reparse/AltTargetPath and (string-length($file/Reparse/AltTargetPath) &gt; 0)"> <!--  and string-length($file/Reparse/AltTargetPath) &gt; 0 -->
				<xsl:value-of select="$file/Reparse/AltTargetPath"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>[Unknown destination]</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>

	<xsl:call-template name="PrintReturn"/>
</xsl:template>

	<xsl:template name="PrintNumberWithCommas">
		<xsl:param name="number" />
		<xsl:param name="space" select="3"/>
		<xsl:variable name="val" select="string($number)" />
		<xsl:choose>
			<xsl:when test="string-length($number) > 3">
				<xsl:call-template name="PrintNumberWithCommas">
					<xsl:with-param name="number" select="substring($val, 0, string-length($val) - 2)"/>
				</xsl:call-template>
				<xsl:text>,</xsl:text>
				<xsl:call-template name="PrintNumberWithCommas">
					<xsl:with-param name="number" select="substring($val, string-length($val) - 2)"/>
				</xsl:call-template>

			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$number"/>
			</xsl:otherwise>

		</xsl:choose>
	</xsl:template>

</xsl:transform>

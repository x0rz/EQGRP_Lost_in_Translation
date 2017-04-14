<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:import href="include/StandardTransforms.xsl" />
	
	
	<xsl:template match="Initial">
		<xsl:text>           PID          PPID        CREATED           CPU TIME        USER</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>-------------------------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn" />
		
		<xsl:for-each select="Process">
			<xsl:text>  </xsl:text>
			<xsl:call-template name="Process">
				<xsl:with-param name="process" select="."/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="Started">
		<xsl:for-each select="Process">
			<xsl:text>+ </xsl:text>
			<xsl:call-template name="Process">
				<xsl:with-param name="process" select="."/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="Stopped">
		<xsl:for-each select="Process">
			<xsl:text>- </xsl:text>
			<xsl:call-template name="Process">
				<xsl:with-param name="process" select="."/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="Process">
		<xsl:param name="process"/>
		
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="12 - string-length($process/@id)" />
		</xsl:call-template>
		<xsl:value-of select="$process/@id" />
		
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="12 - string-length($process/@parent)" />
		</xsl:call-template>
		<xsl:value-of select="$process/@parent" />
		
		<xsl:text>     </xsl:text>
		<xsl:value-of select="substring-before($process/CreateTime, 'T')" />
		<xsl:text> </xsl:text>
		<xsl:value-of select="substring-before(substring-after($process/CreateTime, 'T'), '.')" />
		<xsl:text> </xsl:text>
		
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="25 - string-length($process/CpuTime)" />
		</xsl:call-template>
		<xsl:variable name="days" select="substring-before(substring-after($process/CpuTime, 'P'), 'D')" />
		<xsl:variable name="hours" select="substring-before(substring-after($process/CpuTime, 'T'), 'H')" />
		<xsl:variable name="minutes" select="substring-before(substring-after($process/CpuTime, 'H'), 'M')" />
		<xsl:variable name="seconds" select="substring-before(substring-after($process/CpuTime, 'M'), '.')" />
		<xsl:value-of select="$days"/>
		<xsl:text>.</xsl:text>
		<xsl:value-of select="$hours"/>
		<xsl:text>:</xsl:text>
		<xsl:value-of select="$minutes"/>
		<xsl:text>:</xsl:text>
		<xsl:value-of select="$seconds"/>
		
		<xsl:text>     </xsl:text>
		<xsl:value-of select="$process/@user" />
		
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>  </xsl:text>
		<xsl:choose>
			<xsl:when test="(string-length($process/Name) = 0) and ($process/@id = 0)">
				<xsl:text>System Idle Process</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="string-length($process/ExecutablePath)">
					<xsl:value-of select="$process/ExecutablePath"/>
					<xsl:choose>
						<xsl:when test="contains($process/ExecutablePath, '\')">
							<xsl:text>\</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>/</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<xsl:value-of select="$process/Name" />	
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="$process/Is64Bit">
			<xsl:text> (64-bit)</xsl:text>
		</xsl:if>
		<xsl:if test="$process/Is32Bit">
			<xsl:text> (32-bit)</xsl:text>
		</xsl:if>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>      -------------------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
</xsl:transform>

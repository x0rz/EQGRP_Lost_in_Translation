<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransformsXml.xsl"/>

	<xsl:template match="KiSuInstall">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Good'"/>
			<xsl:with-param name="text">
				<xsl:text>KISU instance </xsl:text>
				<xsl:value-of select="@id"/>
				<xsl:text> (</xsl:text>
				<xsl:value-of select="@name"/>
				<xsl:text>) installed successfully</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="KiSuUninstall">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Good'"/>
			<xsl:with-param name="text">
				<xsl:text>KISU instance </xsl:text>
				<xsl:value-of select="@id"/>
				<xsl:text> (</xsl:text>
				<xsl:value-of select="@name"/>
				<xsl:text>) uninstalled successfully</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="KiSuSurveyPersistence">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Default'"/>
			<xsl:with-param name="text">
				<xsl:text>Persistence methods:</xsl:text>
				<xsl:call-template name="PrintReturn"/>
				<xsl:for-each select="Method">
					<xsl:text>          Type : </xsl:text>
					<xsl:value-of select="Type"/>
					<xsl:call-template name="PrintReturn"/>
					<xsl:text>    Compatible : </xsl:text>
					<xsl:value-of select="Compatible"/>
					<xsl:call-template name="PrintReturn" />
					<xsl:text>        Reason : </xsl:text>
					<xsl:value-of select="Reason"/>
					<xsl:call-template name="PrintReturn" />
					<xsl:call-template name="PrintReturn" />
				</xsl:for-each>
				<xsl:call-template name="PrintReturn" />
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="KiSuUpgrade">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Good'"/>
			<xsl:with-param name="text">
				<xsl:text>Upgrade of instance </xsl:text>
				<xsl:value-of select="@id"/>
				<xsl:text> completed successfully.</xsl:text>
				<xsl:call-template name="PrintReturn" />
			</xsl:with-param>
		</xsl:call-template>
		<xsl:if test="Module">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:call-template name="PrintReturn" />
					<xsl:text>Copied Modules:</xsl:text>
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:call-template name="PrintReturn"/>
					<xsl:text>Module Id         Size       Order      Flags            Name                   Process</xsl:text>
					<xsl:call-template name="PrintReturn"/>
					<xsl:text>===========================================================================================</xsl:text>
					<xsl:call-template name="PrintReturn"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>

		<xsl:for-each select="Module">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:value-of select="@id"/>
					<xsl:text>  </xsl:text>
					<xsl:call-template name="Whitespace">
						<xsl:with-param name="i" select="10 - string-length(@size)"/>
					</xsl:call-template>
					<xsl:value-of select="@size"/>
					<xsl:text>  </xsl:text>
					<xsl:call-template name="Whitespace">
						<xsl:with-param name="i" select="10 - string-length(@order)"/>
					</xsl:call-template>
					<xsl:value-of select="@order"/>
					<xsl:text>    </xsl:text>
					<xsl:value-of select="@flags"/>
					<xsl:text>  </xsl:text>
					<xsl:call-template name="PrintModuleName"/>
					<xsl:text>  </xsl:text>
					<xsl:value-of select="@processName"/>
					<xsl:call-template name="PrintReturn"/>
					<xsl:if test="Md5Hash">
						<xsl:text>    Md5  : </xsl:text>
						<xsl:value-of select="Md5Hash"/>
						<xsl:call-template name="PrintReturn"/>
					</xsl:if>
					
					<xsl:if test="Sha1Hash">
						<xsl:text>    Sha1 : </xsl:text>
						<xsl:value-of select="Sha1Hash"/>
						<xsl:call-template name="PrintReturn"/>
					</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="PrintModuleName">
		<xsl:variable name="modName">
			<xsl:choose>
				<xsl:when test="string-length(@moduleName) &gt; 0">
					<xsl:value-of select="@moduleName"/>
				</xsl:when>
				<xsl:when test="@id = '0xab3f907f'">
					<xsl:text>UserModuleLoader 64-Bit</xsl:text>
				</xsl:when>
				<xsl:when test="@id = '0xbb397f32'">
					<xsl:text>UserModuleLoader 32-Bit</xsl:text>
				</xsl:when>
				<xsl:when test="@id = '0xbb397f34'">
					<xsl:text>Persistence Identifier</xsl:text>
				</xsl:when>
				<xsl:when test="@id = '0xbb397f33'">
					<xsl:text>BH</xsl:text>
				</xsl:when>
				<xsl:when test="@id = '0xbb397f35'">
					<xsl:text>LoadModuleHelperDll</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$modName"/>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="30 - string-length($modName)"/>
		</xsl:call-template>
	</xsl:template>

</xsl:transform>
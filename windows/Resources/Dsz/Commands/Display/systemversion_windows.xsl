<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:template name="PrintWindowsVersion">
		<xsl:text>     Version : </xsl:text>
		<xsl:value-of select="@major" />
		<xsl:text>.</xsl:text>
		<xsl:value-of select="@minor" />
		<xsl:text> (Build </xsl:text>
		<xsl:value-of select="@build" />
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    Platform : </xsl:text>
		<xsl:choose>
			<xsl:when test="(@platform = 'winnt') and (number(@major) = 4)">
				<xsl:text>Windows NT</xsl:text>
			</xsl:when>
			<xsl:when test="(@platform = 'winnt') and (number(@major) = 5) and (number(@minor) = 0)">
				<xsl:text>Windows 2000</xsl:text>
			</xsl:when>
			<xsl:when test="(@platform = 'winnt') and (number(@major) = 5) and (number(@minor) = 1)">
				<xsl:text>Windows XP</xsl:text>
			</xsl:when>
			<xsl:when test="(@platform = 'winnt') and (number(@major) = 5) and (number(@minor) = 2)">
				<xsl:text>Windows 2003</xsl:text>
			</xsl:when>
			<xsl:when test="(@platform = 'winnt') and (number(@major) = 6) and (number(@minor) = 0)">
				<xsl:choose>
					<xsl:when test="Flags/Workstation">
						<xsl:text>Windows Vista</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Windows 2008</xsl:text>		
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="(@platform = 'winnt') and (number(@major) = 6) and (number(@minor) = 1)">
				<xsl:choose>
					<xsl:when test="Flags/Workstation">
						<xsl:text>Windows 7</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Windows 2008</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="(@platform = 'winnt') and (number(@major) = 6) and (number(@minor) = 2)">
				<xsl:choose>
					<xsl:when test="Flags/Workstation">
						<xsl:text>Windows 8</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Windows 2012</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="(@platform = 'win9x') and (number(@major) = 4) and (number(@minor) = 0)">
				<xsl:text>Windows 95</xsl:text>
			</xsl:when>
			<xsl:when test="(@platform = 'win9x') and (number(@major) = 4) and (number(@minor) = 10)">
				<xsl:text>Windows 98</xsl:text>
			</xsl:when>
			<xsl:when test="(@platform = 'win9x') and (number(@major) = 4) and (number(@minor) = 90)">
				<xsl:text>Windows ME</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Unmatched OS</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn" />
		
		<xsl:text>Service Pack : </xsl:text>
		<xsl:value-of select="@revisionMajor" />
		<xsl:text>.</xsl:text>
		<xsl:value-of select="@revisionMinor" />
		<xsl:call-template name="PrintReturn" />
		
		<xsl:text>  Extra Info : </xsl:text>
		<xsl:value-of select="ExtraInfo" />
		<xsl:call-template name="PrintReturn" />
		
		<xsl:text>Product Type : </xsl:text>
		<xsl:if test="Flags/Workstation">
			<xsl:text>Workstation / Professional</xsl:text>
		</xsl:if>
		<xsl:if test="Flags/DomainController">
			<xsl:text>Domain controller</xsl:text>
		</xsl:if>
		<xsl:if test="Flags/Server">
			<xsl:text>Server</xsl:text>
		</xsl:if>
		<xsl:call-template name="PrintReturn" />
		<xsl:if test="Flags/BackOffice">
			<xsl:text>    Microsoft BackOffice components are installed.</xsl:text>
			<xsl:call-template name="PrintReturn" />
		</xsl:if>
		<xsl:if test="Flags/Blade">
			<xsl:text>    Windows .NET Web Server is installed.</xsl:text>
			<xsl:call-template name="PrintReturn" />
		</xsl:if>
		<xsl:if test="Flags/DataCenter">
			<xsl:text>    DataCenter Server is installed.</xsl:text>
			<xsl:call-template name="PrintReturn" />
		</xsl:if>
		<xsl:if test="Flags/Enterprise">
			<xsl:text>    Advanced Server / Enterprise Server is installed.</xsl:text>
			<xsl:call-template name="PrintReturn" />
		</xsl:if>
		<xsl:if test="Flags/SmallBusiness">
			<xsl:text>    Microsoft Small Business Server is installed.</xsl:text>
			<xsl:call-template name="PrintReturn" />
		</xsl:if>
		<xsl:if test="Flags/SmallBusinessRestricted">
			<xsl:text>    Microsoft Small Business Server is installed with the restrictive client license in force.</xsl:text>
			<xsl:call-template name="PrintReturn" />
		</xsl:if>
		<xsl:if test="Flags/Terminal">
			<xsl:text>    Terminal Services is installed.</xsl:text>
			<xsl:call-template name="PrintReturn" />
		</xsl:if>
		<xsl:if test="Flags/EmbeddedNT">
			<xsl:text>    Windows XP Embedded is installed</xsl:text>
			<xsl:call-template name="PrintReturn" />
		</xsl:if>
		<xsl:if test="Flags/Personal">
			<xsl:text>    Windows XP Home Edition is installed.</xsl:text>
			<xsl:call-template name="PrintReturn" />
		</xsl:if>
		<xsl:if test="Flags/SingleUserTS">
			<xsl:text>    Terminal Services is installed, but only one interactive session is supported.</xsl:text>
			<xsl:call-template name="PrintReturn" />
		</xsl:if>
		<!-- print warning for NT4 terminal server -->
		<xsl:if test="(@platform = 'winnt') and (number(@major) = 4) and Flags/TerminalServer">
			<xsl:call-template name="PrintReturn" />
			<xsl:text>    *** NT 4 TERMINAL SERVER ***</xsl:text>
			<xsl:call-template name="PrintReturn" />
		</xsl:if>
	</xsl:template>
	
</xsl:transform>
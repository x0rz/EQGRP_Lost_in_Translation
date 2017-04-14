<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
	<xsl:variable name="indent" select="3" />
  
	<xsl:template match="Enabled">
		<xsl:value-of select="@protocol"/>
		<xsl:text> traffic will be permitted on port </xsl:text>
		<xsl:value-of select="@port"/>
		<xsl:text>.</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:if test="contains(@closePending, 'true')">
			<xsl:text>Exception will be removed when the command ends.</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="NoAction">
		<xsl:text>No action was taken - this iteration of the OS does not support the firewall.</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="Delete">
		<xsl:text>Rule deleted</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
  
	<xsl:template match="Status">
		<!-- Any general settings -->
		<xsl:if test="Standard">
			<xsl:call-template name="FirewallSettings">
				<xsl:with-param name="Settings" select="Standard"/>
				<xsl:with-param name="Name"		select="'Local'"/>
			</xsl:call-template>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:if test="Domain">
			<xsl:call-template name="FirewallSettings">
				<xsl:with-param name="Settings" select="Domain"/>
				<xsl:with-param name="Name"		select="'Domain'"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Private">
			<xsl:call-template name="FirewallSettings">
				<xsl:with-param name="Settings" select="Private"/>
				<xsl:with-param name="Name"		select="'Private'"/>
			</xsl:call-template>		
		</xsl:if>
		<xsl:if test="Public">
			<xsl:call-template name="FirewallSettings">
				<xsl:with-param name="Settings" select="Public"/>
				<xsl:with-param name="Name"		select="'Public'"/>
			</xsl:call-template>		
		</xsl:if>
		<xsl:if test="Local">
			<xsl:call-template name="FirewallSettings">
				<xsl:with-param name="Settings" select="Local"/>
				<xsl:with-param name="Name"		select="'Local'"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="FirewallSettings">
		<xsl:param name="Settings"/>
		<xsl:param name="Name"/>
		
		<xsl:value-of select="$Name"/>
		<xsl:text> Firewall Settings</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="CharFill">
			<xsl:with-param name="i" select="80" />
			<xsl:with-param name="char" select="'-'" />
		</xsl:call-template>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>                 Status:  </xsl:text>
		<xsl:choose>
			<xsl:when test="contains($Settings/@enabled, 'true')">
				<xsl:text>Enabled</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Disabled</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>       Allow Exceptions:  </xsl:text>
		<xsl:choose>
			<xsl:when test="contains($Settings/@exceptions, 'true')">
				<xsl:text>Enabled</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Disabled</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>                 Active:  </xsl:text>
		<xsl:choose>
			<xsl:when test="contains($Settings/@active, 'true')">
				<xsl:text>True</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>False</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text> Default inbound action:  </xsl:text>
		<xsl:choose>
			<xsl:when test="contains($Settings/@inbound, 'allow')">
				<xsl:text>Allow</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Block</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Default outbound action:  </xsl:text>
		<xsl:choose>
			<xsl:when test="contains($Settings/@outbound, 'allow')">
				<xsl:text>Allow</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Block</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn"/>		
		
		<xsl:if test="$Settings/Application">
			<xsl:call-template name="Whitespace">
				<xsl:with-param name="i" select="$indent"/>
			</xsl:call-template>
			<xsl:text>Applications</xsl:text>
			<xsl:call-template name="PrintReturn"/>
			<xsl:for-each select="$Settings/Application">
				<xsl:call-template name="Whitespace">
					<xsl:with-param name="i" select="$indent"/>
				</xsl:call-template>
				<xsl:text>&gt;</xsl:text>
				<xsl:call-template name="Whitespace">
					<xsl:with-param name="i" select="$indent - 1"/>
				</xsl:call-template>
				<xsl:value-of select="ProgramName"/>
				<xsl:text>:  </xsl:text>
				<xsl:value-of select="Program"/>
				<xsl:call-template name="PrintReturn"/>
				<xsl:call-template name="Whitespace">
					<xsl:with-param name="i" select="$indent*3"/>
				</xsl:call-template>
				<xsl:choose>
					<xsl:when test="contains(Scope, '*')">
						<xsl:text>Globally</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="Scope" />
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text> </xsl:text>
				<xsl:value-of select="Status" />
				<xsl:call-template name="PrintReturn"/>
			</xsl:for-each>
		</xsl:if>
		
		<xsl:if test="$Settings/Port">
			<xsl:call-template name="Whitespace">
				<xsl:with-param name="i" select="$indent"/>
			</xsl:call-template>
			<xsl:text>Ports</xsl:text>
			<xsl:call-template name="PrintReturn"/>
			<xsl:call-template name="Whitespace">
				<xsl:with-param name="i" select="$indent"/>
			</xsl:call-template>
			<xsl:call-template name="CharFill">
				<xsl:with-param name="i" select="107-$indent" />
				<xsl:with-param name="char" select="'-'" />
			</xsl:call-template>
			<xsl:call-template name="PrintReturn"/>
			<xsl:call-template name="Whitespace">
				<xsl:with-param name="i" select="$indent*2"/>
			</xsl:call-template>
			<xsl:text>Direction  Action   Port#    Protocol      Scope       Status                  Group             Name</xsl:text>
			<xsl:call-template name="PrintReturn"/>
			<xsl:call-template name="Whitespace">
				<xsl:with-param name="i" select="$indent*2"/>
			</xsl:call-template>
			<xsl:call-template name="CharFill">
				<xsl:with-param name="i" select="107-$indent*2" />
				<xsl:with-param name="char" select="'-'" />
			</xsl:call-template>
			<xsl:call-template name="PrintReturn"/>
			<xsl:for-each select="$Settings/Port">
				<xsl:sort select="Direction"/>
				<xsl:call-template name="Whitespace">
					<xsl:with-param name="i" select="$indent*2"/>
				</xsl:call-template>
				<xsl:call-template name="RightPrint">
					<xsl:with-param name="value" select="Direction"/>
					<xsl:with-param name="space" select="5"/>
				</xsl:call-template>
				<xsl:call-template name="RightPrint">
					<xsl:with-param name="value" select="Action"/>
					<xsl:with-param name="space" select="8"/>
				</xsl:call-template>
				<xsl:choose>
					<xsl:when test="starts-with(Port, '*')">
						<xsl:call-template name="RightPrint">
							<xsl:with-param name="value" select="'Any'"/>
							<xsl:with-param name="space" select="5"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="RightPrint">
							<xsl:with-param name="value" select="Port"/>
							<xsl:with-param name="space" select="5"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:call-template name="CenteredPrint">
					<xsl:with-param name="value" select="Protocol"/>
					<xsl:with-param name="space" select="8"/>
				</xsl:call-template>
				<xsl:choose>
					<xsl:when test="starts-with(Scope, '*')">
						<xsl:call-template name="CenteredPrint">
							<xsl:with-param name="value" select="'Global'"/>
							<xsl:with-param name="space" select="11"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="CenteredPrint">
							<xsl:with-param name="value" select="Scope"/>
							<xsl:with-param name="space" select="11"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:call-template name="CenteredPrint">
					<xsl:with-param name="value" select="Status"/>
					<xsl:with-param name="space" select="8"/>
				</xsl:call-template>
				<xsl:call-template name="CenteredPrint">
					<xsl:with-param name="value" select="Group"/>
					<xsl:with-param name="space" select="27"/>
				</xsl:call-template>
				<xsl:value-of select="PortName"/>
				
				<xsl:call-template name="PrintReturn" />
			</xsl:for-each>	
		</xsl:if>
		
		
		<xsl:call-template name="CharFill">
			<xsl:with-param name="i" select="80" />
			<xsl:with-param name="char" select="'-'" />
		</xsl:call-template>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template name="CenteredPrint">
		<xsl:param name="value"/>
		<xsl:param name="space"/>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="((($space)-string-length($value)) div 2)"/>
		</xsl:call-template>
		<xsl:value-of select="$value"/>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="((($space+1)-string-length($value)) div 2)+3"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="RightPrint">
		<xsl:param name="value"/>
		<xsl:param name="space"/>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="((($space)-string-length($value)))"/>
		</xsl:call-template>
		<xsl:value-of select="$value"/>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="3"/>
		</xsl:call-template>
	</xsl:template>

</xsl:transform>
<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
	<xsl:import href="include/Math.xsl"/>

	<xsl:template match="Connections">
		<xsl:apply-templates select="child::*[node()]"/>
	</xsl:template>
	
	<xsl:template match="Initial">
		<xsl:text>  TYPE PROCESS  LOCAL                                REMOTE                                   STATE</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>---------------------------------------------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:for-each select="Connection">
			<xsl:text> </xsl:text>
			<xsl:call-template name="Connection"/>
		</xsl:for-each>
		<xsl:for-each select="NamedPipe">
			<xsl:text> </xsl:text>
			<xsl:call-template name="NamedPipe"/>
		</xsl:for-each>
		<xsl:for-each select="MailSlot">
			<xsl:text> </xsl:text>
			<xsl:call-template name="MailSlot"/>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="Started">
		<xsl:for-each select="Connection">
			<xsl:text>+</xsl:text>
			<xsl:call-template name="Connection"/>
		</xsl:for-each>
		<xsl:for-each select="NamedPipe">
			<xsl:text>+</xsl:text>
			<xsl:call-template name="NamedPipe"/>
		</xsl:for-each>
		<xsl:for-each select="MailSlot">
			<xsl:text>+</xsl:text>
			<xsl:call-template name="MailSlot"/>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="Stopped">
		<xsl:for-each select="Connection">
			<xsl:text>-</xsl:text>
			<xsl:call-template name="Connection"/>
		</xsl:for-each>
		<xsl:for-each select="NamedPipe">
			<xsl:text>-</xsl:text>
			<xsl:call-template name="NamedPipe"/>
		</xsl:for-each>
		<xsl:for-each select="MailSlot">
			<xsl:text>-</xsl:text>
			<xsl:call-template name="MailSlot"/>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="Connection">
		<xsl:variable name="width" select="35"/>
		<xsl:choose>
			<xsl:when test="@valid">
				<xsl:text> </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>*</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="@type"/>
		<xsl:text>  </xsl:text>
		<xsl:variable name="Process">
			<xsl:choose>
				<xsl:when test="Pid and string-length(Pid) &gt; 0">
					<xsl:call-template name="Whitespace">
						<xsl:with-param name="i" select="5 - string-length(Pid)"/>
					</xsl:call-template>
					<xsl:value-of select="Pid"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="Whitespace">
						<xsl:with-param name="i" select="5"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$Process"/>
		<xsl:text>    </xsl:text>
		<xsl:choose>
			<xsl:when test="LocalAddress/IPv4Address">
				<xsl:call-template name="PrintIpv4">
					<xsl:with-param name="ip" select="LocalAddress/IPv4Address"/>
					<xsl:with-param name="port" select="LocalPort"/>
					<xsl:with-param name="width" select="$width"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="PrintIpv6">
					<xsl:with-param name="ip" select="LocalAddress/IPv6Address"/>
					<xsl:with-param name="port" select="LocalPort"/>
					<xsl:with-param name="width" select="$width"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="RemoteAddress">
				<xsl:text>  </xsl:text>
				<xsl:choose>
					<xsl:when test="RemoteAddress/IPv4Address">
						<xsl:call-template name="PrintIpv4">
							<xsl:with-param name="ip" select="RemoteAddress/IPv4Address"/>
							<xsl:with-param name="port" select="RemotePort"/>
							<xsl:with-param name="width" select="$width"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="PrintIpv6">
							<xsl:with-param name="ip" select="Remote/IPv6Address"/>
							<xsl:with-param name="port" select="RemotePort"/>
							<xsl:with-param name="width" select="$width"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>      </xsl:text>
				<xsl:value-of select="@state"/>
				<xsl:call-template name="Whitespace">
					<xsl:with-param name="i" select="14 - string-length(@state)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="Whitespace">
					<xsl:with-param name="i" select="43"/>
				</xsl:call-template>
				<xsl:value-of select="@state"/>
				<xsl:call-template name="Whitespace">
					<xsl:with-param name="i" select="14 - string-length(@state)"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template name="NamedPipe">
		<xsl:text>Pipe</xsl:text>
		<xsl:text>    </xsl:text>
		<xsl:value-of select="Name"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template name="MailSlot">
		<xsl:text>Mail</xsl:text>
		<xsl:text>    </xsl:text>
		<xsl:value-of select="Name"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template name="PrintIpv4">
		<xsl:param name="ip"/>
		<xsl:param name="port"/>
		<xsl:param name="width"/>

		<xsl:variable name="str">
			<xsl:choose>
				<xsl:when test="string-length($ip) &gt; 0">
					<xsl:value-of select="$ip"/>
					<xsl:text>:</xsl:text>
					<xsl:value-of select="$port"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>*:*</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:value-of select="$str"/>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="$width - string-length($str)"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="PrintIpv6">
		<xsl:param name="ip"/>
		<xsl:param name="port"/>
		<xsl:param name="width"/>
		
		<xsl:variable name="str" >
			<xsl:choose>
				<xsl:when test="($ip = '::') and (string-length($port) = 0)">
					<xsl:text>*:*</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>[</xsl:text>
					<xsl:value-of select="$ip" />
					<xsl:text>]:</xsl:text>
					<xsl:choose>
						<xsl:when test="(string-length($port) = 0) or ($port = 0)">
							<xsl:text>*</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$port"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:value-of select="$str"/>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="$width - string-length($str)"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="PrintBlock">
		<xsl:param name="block" />
		
		<xsl:choose>
			<xsl:when test="string-length($block) = 1">
				<xsl:value-of select="$block"/>
			</xsl:when>
			<xsl:when test="substring($block, 1, 1) = '0'">
				<xsl:call-template name="PrintBlock">
					<xsl:with-param name="block" select="substring($block, 2)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$block"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="ShortenIp6DoubleColon">
		<xsl:param name="ip"/>
		<xsl:param name="shortened" select="0"/>

		<xsl:choose>
			<xsl:when test="substring($ip, 1, 1) = '0'">
				<xsl:if test='$shortened = 0'>
					<xsl:text>::</xsl:text>
				</xsl:if>
				<xsl:call-template name="ShortenIp6DoubleColon">
					<xsl:with-param name="ip" select="substring($ip, 2)"/>
					<xsl:with-param name="shortened" select="1"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
<!--				<xsl:variable name="lower" select="lower-case($ip)" /> -->
				<xsl:variable name="lower" select="$ip" /> 
				<xsl:choose>
					<xsl:when test="contains(substring($lower, 1, 8), 'FFFF0000') and string-length($lower) = 16">
						<xsl:text>ffff</xsl:text> 
						<xsl:call-template name="ConvertToIp4">
							<xsl:with-param name="ipv4" select="substring($lower, 9)"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$ip"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="ConvertToIp4">
		<xsl:param name="ipv4"/>
		
		<xsl:text>:</xsl:text>
		<xsl:variable name="a" select="substring($ipv4, 1, 2)" />
		<xsl:variable name="b" select="substring($ipv4, 3, 2)" />
		<xsl:variable name="c" select="substring($ipv4, 5, 2)" />
		<xsl:variable name="d" select="substring($ipv4, 7, 2)" />

		<xsl:call-template name="math-convert-base">
			<xsl:with-param name="number"    select="$d"/>
			<xsl:with-param name="from-base" select="16"/>
			<xsl:with-param name="to-base"   select="10"/>
		</xsl:call-template>
		<xsl:text>.</xsl:text>
		<xsl:call-template name="math-convert-base">
			<xsl:with-param name="number"    select="$c"/>
			<xsl:with-param name="from-base" select="16"/>
			<xsl:with-param name="to-base"   select="10"/>
		</xsl:call-template>
		<xsl:text>.</xsl:text>
		<xsl:call-template name="math-convert-base">
			<xsl:with-param name="number"    select="$b"/>
			<xsl:with-param name="from-base" select="16"/>
			<xsl:with-param name="to-base"   select="10"/>
		</xsl:call-template>
		<xsl:text>.</xsl:text>
		<xsl:call-template name="math-convert-base">
			<xsl:with-param name="number"    select="$a"/>
			<xsl:with-param name="from-base" select="16"/>
			<xsl:with-param name="to-base"   select="10"/>
		</xsl:call-template>
	</xsl:template>

</xsl:transform>

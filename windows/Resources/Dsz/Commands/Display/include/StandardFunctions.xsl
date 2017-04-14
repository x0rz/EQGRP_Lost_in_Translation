<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  
  <!-- 
	Whitespace(int i)
	    Prints i whitespaces.
  -->
  <xsl:template name="Whitespace">
     <xsl:param name="i"/>
     <xsl:if test="number($i) > 0">
        <xsl:text> </xsl:text>
        <xsl:call-template name="Whitespace">
           <xsl:with-param name="i" select="number($i) - 1"/>
	</xsl:call-template> 
     </xsl:if>
  </xsl:template>
  
  <xsl:template name="Spaceout">
	<xsl:param name="string"/>
	<xsl:param name="i" select="5" />
	
	<xsl:choose>
		<xsl:when test="string-length($string) &lt;= number($i)">
			<xsl:value-of select="$string"/>
		</xsl:when>
		
		<xsl:otherwise>
			<xsl:value-of select="substring($string, 1, $i)"/>
			<xsl:text> </xsl:text>
			<xsl:call-template name="Spaceout">
				<xsl:with-param name="string" select="substring($string, $i+1)" />
				<xsl:with-param name="i" select="$i" />
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>	
  </xsl:template>
  
  <xsl:template name="CharFill">
     <xsl:param name="i"/>
     <xsl:param name="char" />
     <xsl:if test="number($i) > 0">
        <xsl:value-of select="$char" />
        <xsl:call-template name="CharFill">
           <xsl:with-param name="i"    select="number($i) - 1"/>
           <xsl:with-param name="char" select="$char" />
	</xsl:call-template> 
     </xsl:if>
  </xsl:template>

	<xsl:template name="printTime">
		<xsl:param name="time"/>
		<xsl:param name="dateOnly" select="'false'"/>
		<xsl:param name="formatDelta" select="'false'"/>
		
		<xsl:choose>
			<xsl:when test="$time/@type = 'invalid'">
				<xsl:text>invalid</xsl:text>
			</xsl:when>
			<xsl:when test="$time/@type = 'delta'">
				<xsl:variable name="days" select="substring-before(substring-after($time, 'P'), 'D')" />
				<xsl:variable name="hours" select="substring-before(substring-after($time, 'T'), 'H')" />
				<xsl:variable name="minutes" select="substring-before(substring-after($time, 'H'), 'M')" />
				<xsl:variable name="seconds" select="substring-before(substring-after($time, 'M'), '.')" />
				
				<xsl:choose>
					<xsl:when test="$formatDelta = 'true'">
						<xsl:value-of select="$days"/>
						<xsl:text> day(s), </xsl:text>
						<xsl:value-of select="$hours"/>
						<xsl:text> hour(s), </xsl:text>
						<xsl:value-of select="$minutes"/>
						<xsl:text> minute(s), </xsl:text>
						<xsl:value-of select="$seconds"/>
						<xsl:text> second(s)</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$days"/>
						<xsl:text>.</xsl:text>
						<xsl:value-of select="$hours"/>
						<xsl:text>:</xsl:text>
						<xsl:value-of select="$minutes"/>
						<xsl:text>:</xsl:text>
						<xsl:value-of select="$seconds"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring-before($time, 'T')"/>
				<xsl:if test="$dateOnly = 'false'">
					<xsl:text> </xsl:text>
					<xsl:value-of select="substring-before(substring-after($time, 'T'), '.')"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose> 
	</xsl:template>
	
 <xsl:template name="printTimeMDYHMS">
  <xsl:param name="i" />
  <xsl:variable name="date"   select="substring-before($i, 'T')"                          />
  <xsl:variable name="time"   select="substring-after ($i, 'T')"                          />
  <xsl:variable name="year"   select="substring-before($date, '-')"                       />
  <xsl:variable name="month"  select="substring-before(substring-after($date, '-'), '-')" />
  <xsl:variable name="day"    select="substring-after (substring-after($date, '-'), '-')" />
  <xsl:variable name="hour"   select="substring-before($time, ':')"                       />
  <xsl:variable name="minute" select="substring-before(substring-after($time, ':'), ':')" />
  <xsl:variable name="second" select="substring-before(substring-after (substring-after($time, ':'), ':'), '.')" />
  <xsl:value-of select="$month" />
  <xsl:text>/</xsl:text>
  <xsl:value-of select="$day" />
  <xsl:text>/</xsl:text>
  <xsl:value-of select="$year" />
  <xsl:text> </xsl:text>
  <xsl:value-of select="$hour" />
  <xsl:text>:</xsl:text>
  <xsl:value-of select="$minute" />
  <xsl:text>:</xsl:text>
  <xsl:value-of select="$second" />
 </xsl:template>

 <xsl:template name="printTimeHMS">
  <xsl:param name="i" />
  <xsl:variable name="time"   select="substring-after ($i, 'T')"                          />
  <xsl:variable name="hour"   select="substring-before($time, ':')"                       />
  <xsl:variable name="minute" select="substring-before(substring-after($time, ':'), ':')" />
  <xsl:variable name="second" select="substring-before(substring-after (substring-after($time, ':'), ':'), '.')" />
  <xsl:value-of select="$hour" />
  <xsl:text>:</xsl:text>
  <xsl:value-of select="$minute" />
  <xsl:text>:</xsl:text>
  <xsl:value-of select="$second" />

 </xsl:template>

	<xsl:template name="PrintNameFromPath">
		<xsl:param name="path"/>
		<xsl:choose>
			<xsl:when test="contains($path, '/')">
				<xsl:call-template name="PrintNameFromPath">
					<xsl:with-param name="path" select="substring-after($path, '/')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($path, '\')">
				<xsl:call-template name="PrintNameFromPath">
					<xsl:with-param name="path" select="substring-after($path, '\')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$path"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="PrintNumberWithCommas">
		<xsl:param name="number" />
		<xsl:param name="space" select="0"/>
		
		<xsl:variable name="val" select="string(floor($number))" />
		
		<xsl:choose>
			<xsl:when test="string-length($number) > 3">
				<xsl:call-template name="PrintNumberWithCommas">
					<xsl:with-param name="number" select="substring($val, 0, string-length($val) - 2)"/>
					<xsl:with-param name="space" select="0"/>
				</xsl:call-template>
				<xsl:text>,</xsl:text>
				<xsl:call-template name="PrintNumberWithCommas">
					<xsl:with-param name="number" select="substring($val, string-length($val) - 2)"/>
					<xsl:with-param name="space" select="0"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$number"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="$space"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="PrintReturn">
		<xsl:text>&#x0A;</xsl:text>
	</xsl:template>

	<xsl:template name="PrintTab">
		<xsl:text>&#x09;</xsl:text>
	</xsl:template>
	
	<xsl:template name="PrintBinary">
		<xsl:param name="data"/>
		<xsl:variable name="lines" select="ceiling(string-length($data) div 32)" />
		
		<xsl:choose>
			<xsl:when test="$lines > 1">
				<xsl:variable name="firsthalf" select="ceiling($lines div 2)"/>
				<xsl:call-template name="PrintBinary">
					<xsl:with-param name="data" select="substring($data, 1, $firsthalf * 32)"/>
				</xsl:call-template>
				<xsl:call-template name="PrintBinary">
					<xsl:with-param name="data" select="substring($data, ($firsthalf * 32) + 1)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="PrintBinaryLine">
					<xsl:with-param name="data" select="$data"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
    
	<xsl:template name="PrintBinaryLine">
		<xsl:param name="data"/>

		<!-- set the values -->
		<xsl:variable name="val1"  select="substring($data, 1, 2)"/>
		<xsl:variable name="val2"  select="substring($data, 3, 2)"/>
		<xsl:variable name="val3"  select="substring($data, 5, 2)"/>
		<xsl:variable name="val4"  select="substring($data, 7, 2)"/>
		<xsl:variable name="val5"  select="substring($data, 9, 2)"/>
		<xsl:variable name="val6"  select="substring($data, 11, 2)"/>
		<xsl:variable name="val7"  select="substring($data, 13, 2)"/>
		<xsl:variable name="val8"  select="substring($data, 15, 2)"/>
		<xsl:variable name="val9"  select="substring($data, 17, 2)"/>
		<xsl:variable name="val10" select="substring($data, 19, 2)"/>
		<xsl:variable name="val11" select="substring($data, 21, 2)"/>
		<xsl:variable name="val12" select="substring($data, 23, 2)"/>
		<xsl:variable name="val13" select="substring($data, 25, 2)"/>
		<xsl:variable name="val14" select="substring($data, 27, 2)"/>
		<xsl:variable name="val15" select="substring($data, 29, 2)"/>
		<xsl:variable name="val16" select="substring($data, 31, 2)"/>

		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="4"/>
		</xsl:call-template>

		<xsl:value-of select="$val1"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="$val2"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="$val3"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="$val4"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="$val5"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="$val6"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="$val7"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="$val8"/>
		<xsl:text> </xsl:text>
		<xsl:text> </xsl:text>
		<xsl:value-of select="$val9"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="$val10"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="$val11"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="$val12"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="$val13"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="$val14"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="$val15"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="$val16"/>

		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="36 - string-length($data)"/>
		</xsl:call-template>
		<xsl:text>|</xsl:text>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="4"/>
		</xsl:call-template>
		
		<xsl:if test="$val1">
			<xsl:call-template name="PrintCharacter">
				<xsl:with-param name="char" select="$val1"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$val2">
			<xsl:call-template name="PrintCharacter">
				<xsl:with-param name="char" select="$val2"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$val3">
			<xsl:call-template name="PrintCharacter">
				<xsl:with-param name="char" select="$val3"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$val4">
			<xsl:call-template name="PrintCharacter">
				<xsl:with-param name="char" select="$val4"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$val5">
			<xsl:call-template name="PrintCharacter">
				<xsl:with-param name="char" select="$val5"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$val6">
			<xsl:call-template name="PrintCharacter">
				<xsl:with-param name="char" select="$val6"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$val7">
			<xsl:call-template name="PrintCharacter">
				<xsl:with-param name="char" select="$val7"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$val8">
			<xsl:call-template name="PrintCharacter">
				<xsl:with-param name="char" select="$val8"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:text> </xsl:text>
		<xsl:if test="$val9">
			<xsl:call-template name="PrintCharacter">
				<xsl:with-param name="char" select="$val9"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$val10">
			<xsl:call-template name="PrintCharacter">
				<xsl:with-param name="char" select="$val10"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$val11">
			<xsl:call-template name="PrintCharacter">
				<xsl:with-param name="char" select="$val11"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$val12">
			<xsl:call-template name="PrintCharacter">
				<xsl:with-param name="char" select="$val12"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$val13">
			<xsl:call-template name="PrintCharacter">
				<xsl:with-param name="char" select="$val13"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$val14">
			<xsl:call-template name="PrintCharacter">
				<xsl:with-param name="char" select="$val14"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$val15">
			<xsl:call-template name="PrintCharacter">
				<xsl:with-param name="char" select="$val15"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$val16">
			<xsl:call-template name="PrintCharacter">
				<xsl:with-param name="char" select="$val16"/>
			</xsl:call-template>
		</xsl:if>
	    
		<xsl:text>&#x0A;</xsl:text>

	</xsl:template>

	<xsl:template name="PrintCharacter">
		<xsl:param name="char"/>
    
		<xsl:choose>
			<xsl:when test="$char = '20'"><xsl:text> </xsl:text></xsl:when>
			<xsl:when test="$char = '21'">&#x21;</xsl:when>
			<xsl:when test="$char = '22'">&#x22;</xsl:when>
			<xsl:when test="$char = '23'">&#x23;</xsl:when>
			<xsl:when test="$char = '24'">&#x24;</xsl:when>
			<xsl:when test="$char = '25'">&#x25;</xsl:when>
			<xsl:when test="$char = '26'">&#x26;</xsl:when>
			<xsl:when test="$char = '27'">&#x27;</xsl:when>
			<xsl:when test="$char = '28'">&#x28;</xsl:when>
			<xsl:when test="$char = '29'">&#x29;</xsl:when>
			<xsl:when test="$char = '2a'">&#x2A;</xsl:when>
			<xsl:when test="$char = '2b'">&#x2b;</xsl:when>
			<xsl:when test="$char = '2c'">&#x2c;</xsl:when>
			<xsl:when test="$char = '2d'">&#x2d;</xsl:when>
			<xsl:when test="$char = '2e'">&#x2e;</xsl:when>
			<xsl:when test="$char = '2f'">&#x2f;</xsl:when>
			<xsl:when test="$char = '30'">&#x30;</xsl:when>
			<xsl:when test="$char = '31'">&#x31;</xsl:when>
			<xsl:when test="$char = '32'">&#x32;</xsl:when>
			<xsl:when test="$char = '33'">&#x33;</xsl:when>
			<xsl:when test="$char = '34'">&#x34;</xsl:when>
			<xsl:when test="$char = '35'">&#x35;</xsl:when>
			<xsl:when test="$char = '36'">&#x36;</xsl:when>
			<xsl:when test="$char = '37'">&#x37;</xsl:when>
			<xsl:when test="$char = '38'">&#x38;</xsl:when>
			<xsl:when test="$char = '39'">&#x39;</xsl:when>
			<xsl:when test="$char = '3a'">&#x3a;</xsl:when>
			<xsl:when test="$char = '3b'">&#x3b;</xsl:when>
			<xsl:when test="$char = '3c'">&#x3c;</xsl:when>
			<xsl:when test="$char = '3d'">&#x3d;</xsl:when>
			<xsl:when test="$char = '3e'">&#x3e;</xsl:when>
			<xsl:when test="$char = '3f'">&#x3f;</xsl:when>
			<xsl:when test="$char = '40'">&#x40;</xsl:when>
			<xsl:when test="$char = '41'">&#x41;</xsl:when>
			<xsl:when test="$char = '42'">&#x42;</xsl:when>
			<xsl:when test="$char = '43'">&#x43;</xsl:when>
			<xsl:when test="$char = '44'">&#x44;</xsl:when>
			<xsl:when test="$char = '45'">&#x45;</xsl:when>
			<xsl:when test="$char = '46'">&#x46;</xsl:when>
			<xsl:when test="$char = '47'">&#x47;</xsl:when>
			<xsl:when test="$char = '48'">&#x48;</xsl:when>
			<xsl:when test="$char = '49'">&#x49;</xsl:when>
			<xsl:when test="$char = '4a'">&#x4a;</xsl:when>
			<xsl:when test="$char = '4b'">&#x4b;</xsl:when>
			<xsl:when test="$char = '4c'">&#x4c;</xsl:when>
			<xsl:when test="$char = '4d'">&#x4d;</xsl:when>
			<xsl:when test="$char = '4e'">&#x4e;</xsl:when>
			<xsl:when test="$char = '4f'">&#x4f;</xsl:when>
			<xsl:when test="$char = '50'">&#x50;</xsl:when>
			<xsl:when test="$char = '51'">&#x51;</xsl:when>
			<xsl:when test="$char = '52'">&#x52;</xsl:when>
			<xsl:when test="$char = '53'">&#x53;</xsl:when>
			<xsl:when test="$char = '54'">&#x54;</xsl:when>
			<xsl:when test="$char = '55'">&#x55;</xsl:when>
			<xsl:when test="$char = '56'">&#x56;</xsl:when>
			<xsl:when test="$char = '57'">&#x57;</xsl:when>
			<xsl:when test="$char = '58'">&#x58;</xsl:when>
			<xsl:when test="$char = '59'">&#x59;</xsl:when>
			<xsl:when test="$char = '5a'">&#x5a;</xsl:when>
			<xsl:when test="$char = '5b'">&#x5b;</xsl:when>
			<xsl:when test="$char = '5c'">&#x5c;</xsl:when>
			<xsl:when test="$char = '5d'">&#x5d;</xsl:when>
			<xsl:when test="$char = '5e'">&#x5e;</xsl:when>
			<xsl:when test="$char = '5f'">&#x5f;</xsl:when>
			<xsl:when test="$char = '60'">&#x60;</xsl:when>
			<xsl:when test="$char = '61'">&#x61;</xsl:when>
			<xsl:when test="$char = '62'">&#x62;</xsl:when>
			<xsl:when test="$char = '63'">&#x63;</xsl:when>
			<xsl:when test="$char = '64'">&#x64;</xsl:when>
			<xsl:when test="$char = '65'">&#x65;</xsl:when>
			<xsl:when test="$char = '66'">&#x66;</xsl:when>
			<xsl:when test="$char = '67'">&#x67;</xsl:when>
			<xsl:when test="$char = '68'">&#x68;</xsl:when>
			<xsl:when test="$char = '69'">&#x69;</xsl:when>
			<xsl:when test="$char = '6a'">&#x6a;</xsl:when>
			<xsl:when test="$char = '6b'">&#x6b;</xsl:when>
			<xsl:when test="$char = '6c'">&#x6c;</xsl:when>
			<xsl:when test="$char = '6d'">&#x6d;</xsl:when>
			<xsl:when test="$char = '6e'">&#x6e;</xsl:when>
			<xsl:when test="$char = '6f'">&#x6f;</xsl:when>
			<xsl:when test="$char = '70'">&#x70;</xsl:when>
			<xsl:when test="$char = '71'">&#x71;</xsl:when>
			<xsl:when test="$char = '72'">&#x72;</xsl:when>
			<xsl:when test="$char = '73'">&#x73;</xsl:when>
			<xsl:when test="$char = '74'">&#x74;</xsl:when>
			<xsl:when test="$char = '75'">&#x75;</xsl:when>
			<xsl:when test="$char = '76'">&#x76;</xsl:when>
			<xsl:when test="$char = '77'">&#x77;</xsl:when>
			<xsl:when test="$char = '78'">&#x78;</xsl:when>
			<xsl:when test="$char = '79'">&#x79;</xsl:when>
			<xsl:when test="$char = '7a'">&#x7a;</xsl:when>
			<xsl:when test="$char = '7b'">&#x7b;</xsl:when>
			<xsl:when test="$char = '7c'">&#x7c;</xsl:when>
			<xsl:when test="$char = '7d'">&#x7d;</xsl:when>
			<xsl:when test="$char = '7e'">&#x7e;</xsl:when>
			<xsl:otherwise>.</xsl:otherwise>
		</xsl:choose>
		<xsl:text> </xsl:text>
	</xsl:template>
  
</xsl:transform>

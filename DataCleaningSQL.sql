
select * 
from PortfolioProject.dbo.Housing


------------------------------------------------------------------------------------------------------------

--Modify the date format

select saleDateConv , convert(date,saledate)
from PortfolioProject.dbo.Housing


alter table housing 
add saleDateConv Date;

update Housing
set saleDateConv = convert(date,saledate)



------------------------------------------------------------------------------------------------------------


-- populate propertyAdresse when null

select x.ParcelID, x.PropertyAddress, y.ParcelID, y.PropertyAddress, isnull(x.PropertyAddress,y.PropertyAddress)
from PortfolioProject.dbo.Housing x
join PortfolioProject.dbo.Housing y
  on x.[UniqueID ] <> y.[UniqueID ] 
where x.PropertyAddress is null 

update x
set PropertyAddress = isnull(x.PropertyAddress,y.PropertyAddress)
from PortfolioProject.dbo.Housing x
join PortfolioProject.dbo.Housing y
  on x.[UniqueID ] <> y.[UniqueID ] 
where x.PropertyAddress is null 



------------------------------------------------------------------------------------------------------------



-- breaking propertyAdress into individual colums: Adress, City ( using substring()  )

select substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1 ) as Adress1,
       substring(PropertyAddress,  charindex(',', PropertyAddress)+1, len(PropertyAddress)) as Adress2

from PortfolioProject.dbo.Housing 


alter table housing
add PropertySplitAddress Nvarchar(255);

update Housing 
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1 )


alter table housing
add PropertySplitCity  Nvarchar(255);

update housing 
set PropertySplitCity = substring(PropertyAddress,  charindex(',', PropertyAddress)+1, len(PropertyAddress))


select * 
from PortfolioProject.dbo.Housing


------------------------------------------------------------------------------------------------------------


-- breaking ownerAdress into individual colums: Adress, City, State( using parsename() )

select OwnerAddress
from PortfolioProject.dbo.Housing 

select 
parsename(replace(OwnerAddress, ',', '.'),  3),
parsename(replace(OwnerAddress, ',', '.'),  2),
parsename(replace(OwnerAddress, ',', '.'),  1)
from PortfolioProject.dbo.Housing 

alter table housing
add OwnerSplitAddress Nvarchar(255);

update Housing 
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'),  3)


alter table housing
add OwnerSplitCity  Nvarchar(255);

update housing 
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'),  2)

alter table housing
add OwnerSplitState  Nvarchar(255);

update housing 
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'),  1)


select * 
from PortfolioProject.dbo.Housing


------------------------------------------------------------------------------------------------------------


-- Change Y to yes and N to no in Sold as Vacant

select Distinct(SOldAsVacant), Count(SoldAsVacant)
from PortfolioProject.dbo.Housing
Group by SoldAsVacant
order by 2



select SoldAsvacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject.dbo.Housing

update housing 
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
                        when SoldAsVacant = 'N' then 'No'
	                    else SoldAsVacant
	                    end



------------------------------------------------------------------------------------------------------------



-- Remove Duplicates 

with RowNumCTE as(
Select *,
  ROW_NUMBER() over (
  partition by ParcelID,
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   order by 
			     UniqueID
				 ) row_num

from PortfolioProject.dbo.Housing
--order by ParcelID
)
select * 
from RowNumCTE
where row_num > 1
--order By PropertyAddress



------------------------------------------------------------------------------------------------------------


-- deleting some unsused columns

alter table PortfolioProject.dbo.Housing
drop column OwnerAddress, TaxDistrict, PropertyAddress , SaleDate

Select *
from PortfolioProject.dbo.Housing
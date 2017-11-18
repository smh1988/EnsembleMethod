% a2. Image gradient function. 
function dx = HGM(image)
    for k = 1:size(image, 3)
       image(:, :, k) = gradient(double(image(:, :, k)));
    end
    %dx = reshape(max( abs(image), [], 3 ), 1, []); 
%     dx = dx(:)./max(dx(:)); 
dx=max( abs(image), [], 3 );
end

